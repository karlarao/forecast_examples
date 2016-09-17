--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- xcorr
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE xcorr(p_in_table   VARCHAR2, 
                                  p_out_table  VARCHAR2, 
                                  p_seq_col    VARCHAR2,
                                  p_base_col   VARCHAR2,
                                  p_lag_col    VARCHAR2,
                                  p_max_lag    NUMBER) AS
   v_stmt VARCHAR2(4000);
   v_corr NUMBER;
BEGIN
   v_stmt:= 'CREATE TABLE ' || p_out_table || 
            '(lag_num NUMBER, correlation NUMBER)';
   EXECUTE IMMEDIATE v_stmt;

   FOR i IN 1..p_max_lag LOOP
      v_stmt:=
        'SELECT CORR(' || p_base_col || ', lag_val) ' ||
        'FROM (SELECT ' || p_base_col || ',' ||
                      'LAG(' || p_lag_col || ',' || i || ') ' ||
                      'OVER(ORDER BY ' || p_seq_col || ') lag_val ' ||
              'FROM ' || p_in_table || ')';
      EXECUTE IMMEDIATE v_stmt INTO v_corr;
      v_stmt:='INSERT INTO ' ||  p_out_table ||
             ' (lag_num, correlation) VALUES(:v1, :v2)';
      EXECUTE IMMEDIATE v_stmt using i, v_corr;
   END LOOP;        
END;
/
SHOW ERRORS;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- TS examples
--------------------------------------------------------------------------
--------------------------------------------------------------------------
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- PASSENGERS
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Data and modeling
-- data: http://oracledmt.googlepages.com/data_airline.csv
--------------------------------------------------------------------------
-- Stabilize the data (remove trend and stabilize variance)
CREATE OR REPLACE VIEW airline_xfrm AS
SELECT a.*
FROM (SELECT month, passengers, 
             tp - LAG(tp,1) OVER (ORDER BY month) tp
      FROM   (SELECT month, passengers, LOG(10,PASSENGERS) tp
              FROM   airline)) a;

-- Information used in the normalization
SELECT  AVG(tp) shift, STDDEV(tp) scale
      FROM airline_xfrm
      WHERE month < 132;

-- Normalize the data
CREATE OR REPLACE VIEW airline_norm AS
SELECT month, passengers, (tp - .003919158)/.046271162 tp
FROM airline_xfrm;

-- Compute lags
DROP TABLE airline_xcorr PURGE;
execute xcorr('airline_norm', 'airline_xcorr','month','tp','tp', 20);
SELECT * FROM airline_xcorr ORDER BY lag_num;

-- Create lagged view
CREATE OR REPLACE VIEW airline_lag AS 
SELECT a.*
FROM (SELECT month, passengers, tp,
             LAG(tp, 1)  OVER (ORDER BY month) L1,
             LAG(tp, 2)  OVER (ORDER BY month) L2,
             LAG(tp, 3)  OVER (ORDER BY month) L3,
             LAG(tp, 4)  OVER (ORDER BY month) L4,
             LAG(tp, 5)  OVER (ORDER BY month) L5,
             LAG(tp, 6)  OVER (ORDER BY month) L6,
             LAG(tp, 7)  OVER (ORDER BY month) L7,
             LAG(tp, 8)  OVER (ORDER BY month) L8,
             LAG(tp, 9)  OVER (ORDER BY month) L9,
             LAG(tp, 10) OVER (ORDER BY month) L10,
             LAG(tp, 11) OVER (ORDER BY month) L11,
             LAG(tp, 12) OVER (ORDER BY month) L12
      FROM airline_norm) a;

-- Data for building
CREATE OR REPLACE VIEW airline_train AS 
SELECT month, tp, L1, L2, L3, L4, L5, L6, L7, L8, L9, L10, L11, L12
FROM   airline_lag a
WHERE  month > 13 AND month < 132;

-- Build model
EXECUTE dbms_data_mining.drop_model('airline_svm');
BEGIN
  DBMS_DATA_MINING.CREATE_MODEL(
    model_name          => 'airline_SVM',
    mining_function     => dbms_data_mining.regression,
    data_table_name     => 'airline_train',
    case_id_column_name => 'month',
    target_column_name  => 'tp');
END;
/

--------------------------------------------------------------------------
-- Forecast (includes all transformations)
--------------------------------------------------------------------------
CREATE OR REPLACE VIEW airline_forecast AS
SELECT m month, p passengers, pred
FROM airline a
MODEL
  DIMENSION BY (month m)
  MEASURES (a.passengers p, 
            CAST(NULL AS NUMBER) ap, CAST(NULL AS NUMBER) tp, 
            CAST(NULL AS NUMBER) tpred, CAST(NULL AS NUMBER) npred,
            CAST(NULL AS NUMBER) dpred, CAST(NULL AS NUMBER) pred)
  RULES(
    ap [FOR m FROM 1 TO 131 INCREMENT 1] = p[CV()],
    tp[FOR m FROM 1 TO 131 INCREMENT 1] = 
      (LOG(10,ap[CV()]) - LOG(10,ap[CV()-1]) - .003919158)/.046271162,
    tpred[FOR m FROM 1 TO 144 INCREMENT 1] = 
              PREDICTION(airline_SVM USING 
                           NVL(tp[CV()-1],tpred[CV()-1]) as l1,
                           NVL(tp[CV()-2],tpred[CV()-2]) as l2,
                           NVL(tp[CV()-3],tpred[CV()-3]) as l3,
                           NVL(tp[CV()-4],tpred[CV()-4]) as l4,
                           NVL(tp[CV()-5],tpred[CV()-5]) as l5,
                           NVL(tp[CV()-6],tpred[CV()-6]) as l6,
                           NVL(tp[CV()-7],tpred[CV()-7]) as l7,
                           NVL(tp[CV()-8],tpred[CV()-8]) as l8,
                           NVL(tp[CV()-9],tpred[CV()-9]) as l9,
                           NVL(tp[CV()-10],tpred[CV()-10]) as l10,
                           NVL(tp[CV()-11],tpred[CV()-11]) as l11,
                           NVL(tp[CV()-12],tpred[CV()-12]) as l12),
    npred[FOR m FROM 1 TO 144 INCREMENT 1] = 
              0.003919158 + 0.046271162 * tpred[CV()],
    dpred[FOR m FROM 1 TO 144 INCREMENT 1] = 
              npred[CV()] + NVL(LOG(10,ap[CV()-1]),dpred[CV()-1]),
    pred[FOR m FROM 1 TO 144 INCREMENT 1] = POWER(10,dpred[CV()])
  )
ORDER BY m;

-- Compute RMSE and MAE for training period
SELECT SQRT(AVG((passengers-pred)*(passengers-pred))) rmse, 
       AVG(ABS(passengers-pred)) mae
FROM airline_forecast
WHERE month > 13 AND month<132;

-- Compute RMSE and MAE for testing period
SELECT SQRT(AVG((passengers-pred)*(passengers-pred))) rmse, 
       AVG(ABS(passengers-pred)) mae
FROM airline_forecast
WHERE month > 131;

--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- ELECTRIC LOAD
--------------------------------------------------------------------------
--------------------------------------------------------------------------
-- Data and modeling
-- data: http://oracledmt.googlepages.com/data_electric_load.csv
--------------------------------------------------------------------------
-- Information for normalizing the data
SELECT MIN(max_load) shift, 
       (MAX(max_load) - MIN(max_load)) scale
FROM load_all
WHERE day_id < 731;

-- Normalize the data
CREATE OR REPLACE VIEW load_norm AS
SELECT day_id, day, max_load, holiday, to_char(day,'d') day_week, 
       (max_load-464)/412 tl
FROM load_all;

-- Compute lags
DROP TABLE load_xcorr PURGE;
EXECUTE  xcorr('load_norm','load_xcorr','day_id','tl','tl',20);
SELECT * FROM load_xcorr ORDER BY lag_num;

-- Create lagged view
CREATE OR REPLACE VIEW load_lag as
SELECT day_id, day, max_load, tl, holiday, day_week,
             LAG(tl, 1)  OVER (ORDER BY day) L1,
             LAG(tl, 2)  OVER (ORDER BY day) L2,
             LAG(tl, 3)  OVER (ORDER BY day) L3,
             LAG(tl, 4)  OVER (ORDER BY day) L4,
             LAG(tl, 5)  OVER (ORDER BY day) L5,
             LAG(tl, 6)  OVER (ORDER BY day) L6,
             LAG(tl, 7)  OVER (ORDER BY day) L7
FROM load_norm;

-- Data for building the model
CREATE OR REPLACE VIEW load_train AS
SELECT day_id, tl, holiday, day_week, 
       L1, L2, L3, L4, L5, L6, L7
FROM load_lag 
WHERE day_id < 731 and day_id > 7;

-- Build model
EXECUTE dbms_data_mining.drop_model('load_svm');
BEGIN
  DBMS_DATA_MINING.CREATE_MODEL(
    model_name          => 'load_SVM',
    mining_function     => dbms_data_mining.regression,
    data_table_name     => 'load_train',
    case_id_column_name => 'day_id',
    target_column_name  => 'tl');
END;
/

--------------------------------------------------------------------------
-- Forecast
--------------------------------------------------------------------------
CREATE OR REPLACE VIEW load_forecast AS
SELECT m day_id, p max_load, pred
FROM load_all a
MODEL
  DIMENSION BY (day_id m)
  MEASURES (a.max_load p, to_char(a.day,'d') dw, a.holiday h,
            CAST(NULL AS NUMBER) ap, CAST(NULL AS NUMBER) tp,
            CAST(NULL AS NUMBER) tpred, 
            CAST(NULL AS NUMBER) pred)
  RULES(
    ap[FOR m FROM 1 TO 730 INCREMENT 1] = p[CV()],
    h[FOR m FROM 731 TO 761 INCREMENT 1] = 0,
    tp[FOR m FROM 1 TO 730 INCREMENT 1] = 
              (ap[CV()]  - 464)/412,
    tpred[FOR m FROM 1 TO 761 INCREMENT 1] = 
              PREDICTION(load_SVM USING
                           NVL(tp[CV()-1],tpred[CV()-1]) as l1,
                           NVL(tp[CV()-2],tpred[CV()-2]) as l2,
                           NVL(tp[CV()-3],tpred[CV()-3]) as l3,
                           NVL(tp[CV()-4],tpred[CV()-4]) as l4,
                           NVL(tp[CV()-5],tpred[CV()-5]) as l5,
                           NVL(tp[CV()-6],tpred[CV()-6]) as l6,
                           NVL(tp[CV()-7],tpred[CV()-7]) as l7, 
                           dw[CV()] as day_week,
                           h[CV()] as holiday
                ),
    pred[FOR m FROM 1 TO 761 INCREMENT 1] = 
              464 + 412 * tpred[CV()]
  )
ORDER BY m;

-- Compute MAPE and Max_Err for training period
SELECT 100*AVG(ABS(max_load-pred)/max_load) mape, 
       MAX(ABS(max_load-pred)) max_err
FROM load_forecast
WHERE day_id > 7 AND day_id<731;

-- Compute MAPE and Max_Err for testing period
SELECT 100*AVG(ABS(max_load-pred)/max_load) mape, 
       MAX(ABS(max_load-pred)) max_err
FROM load_forecast
WHERE day_id > 730;

