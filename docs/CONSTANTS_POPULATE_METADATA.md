# Steps to update constants.json

## gather required data
- ownerId = 122020099
- copy constants.json from base environment - test_data\environments\QA29_B0\constants.json to the target environment folder e.g., test_data\environments\{TARGET_ENV}\constants.json

## DayOffReasonType
Better approach is to go to roster->req calendar add day off and see the reason codes available there.

OR 

unpaid reason
```
select cv.CODE_VALUE ,cv.CODE_DESCRIPTION from code_value WHERE CODESET_ID ='RWS_TIMEOFF_RSN_U' AND owner_id=122020099;
```
paid reason
```
select cv.CODE_VALUE ,cv.CODE_DESCRIPTION from code_value WHERE CODESET_ID ='RWS_TIMEOFF_RSN_P' AND owner_id=122020099;
```
TODO: need confirmation from Engg. this is very generic SQL query. 

## AvailabilityReasonType 
```
select cv.CODE_VALUE ,cv.CODE_DESCRIPTION  from CODE_VALUE cv WHERE cv.CODESET_ID ='AVL_DEN_RSN_CD' AND owner_id=122020099;
```
pick any CODE_DESCRIPTION 
TODO: do we need 3 values here - action -> QE

## TimeCardReasonCodes
select cv.CODE_VALUE ,cv.CODE_DESCRIPTION from CODE_VALUE cv  WHERE cv.CODESET_ID ='RTA_TIMECARD_REASON' AND owner_id=122020099; 
pick any CODE_DESCRIPTION 

- Autopopulated in env_config_sync tool from metadata.yaml

# SpecialPayReasonCodes
select CONCAT('CODE',ROW_NUMBER() OVER(ORDER BY SEQUENCE_NO ASC)) AS row_num, cv.CODE_DESCRIPTION from CODE_VALUE cv  WHERE cv.CODESET_ID ='RTA_SP_PAY_REASON' AND owner_id=122020099 ORDER BY SEQUENCE_NO FETCH FIRST 2 ROW ONLY;
- Autopopulated in env_config_sync tool from metadata.yaml