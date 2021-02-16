*** Settings ***
Variables                   ../../../variables/common.py
  
Library                     ../${RESOURCES}/neofs.py
Library                     ../${RESOURCES}/payment_neogo.py

Resource                    common_steps_acl_basic.robot


*** Test cases ***
Basic ACL Operations for Read-Only Container
    [Documentation]         Testcase to validate NeoFS operations with ACL for Read-Only Container.
    [Tags]                  ACL  NeoFS  NeoCLI
    [Timeout]               20 min

                            Generate Keys

                            Create Containers
                            Generate file    1024
                            Check Read-Only Container    Simple
                            
                            Create Containers
                            Generate file    70e+6
                            Check Read-Only Container    Complex

    [Teardown]              Cleanup  
    

*** Keywords ***


Check Read-Only Container
    [Arguments]     ${RUN_TYPE}

    # Put
    ${S_OID_USER} =         Put object                 ${USER_KEY}         ${FILE_S}    ${READONLY_CID}    ${EMPTY}    ${EMPTY}
                            Run Keyword And Expect Error        *
                            ...  Put object            ${OTHER_KEY}        ${FILE_S}    ${READONLY_CID}    ${EMPTY}    ${EMPTY}
                            Run Keyword And Expect Error        *
                            ...  Put object            ${SYSTEM_KEY_IR}    ${FILE_S}    ${READONLY_CID}    ${EMPTY}    ${EMPTY}
    ${S_OID_SYS_SN} =       Put object                 ${SYSTEM_KEY_SN}    ${FILE_S}    ${READONLY_CID}    ${EMPTY}    ${EMPTY}


    # Storage group Operations (Put, List, Get, Delete)
    ${SG_OID_INV} =     Put Storagegroup    ${USER_KEY}    ${READONLY_CID}   ${EMPTY}    ${S_OID_USER}
    ${SG_OID_1} =       Put Storagegroup    ${USER_KEY}    ${READONLY_CID}   ${EMPTY}    ${S_OID_USER}
                        List Storagegroup    ${USER_KEY}    ${READONLY_CID}    ${SG_OID_1}  ${SG_OID_INV}
    @{EXPECTED_OIDS} =  Run Keyword If    "${RUN_TYPE}" == "Complex"    Get Split objects    ${USER_KEY}    ${READONLY_CID}   ${S_OID_USER}
                        ...    ELSE IF   "${RUN_TYPE}" == "Simple"    Create List   ${S_OID_USER} 		
                        Get Storagegroup    ${USER_KEY}    ${READONLY_CID}    ${SG_OID_1}    ${EMPTY}    @{EXPECTED_OIDS}
                        Delete Storagegroup    ${USER_KEY}    ${READONLY_CID}    ${SG_OID_1}

                        Run Keyword And Expect Error        *
                        ...  Put Storagegroup    ${OTHER_KEY}    ${READONLY_CID}   ${EMPTY}    ${S_OID_USER}
                        List Storagegroup    ${OTHER_KEY}    ${READONLY_CID}    ${SG_OID_INV}
    @{EXPECTED_OIDS} =  Run Keyword If    "${RUN_TYPE}" == "Complex"    Get Split objects    ${USER_KEY}    ${READONLY_CID}   ${S_OID_USER}
                        ...    ELSE IF   "${RUN_TYPE}" == "Simple"    Create List   ${S_OID_USER} 		
                        Get Storagegroup    ${OTHER_KEY}    ${READONLY_CID}    ${SG_OID_INV}    ${EMPTY}    @{EXPECTED_OIDS}
                        Run Keyword And Expect Error        *
                        ...  Delete Storagegroup    ${OTHER_KEY}    ${READONLY_CID}    ${SG_OID_INV}

                        Run Keyword And Expect Error        *
                        ...  Put Storagegroup    ${SYSTEM_KEY_IR}    ${READONLY_CID}   ${EMPTY}    ${S_OID_USER}
                        List Storagegroup    ${SYSTEM_KEY_IR}    ${READONLY_CID}    ${SG_OID_INV}
    @{EXPECTED_OIDS} =  Run Keyword If    "${RUN_TYPE}" == "Complex"    Get Split objects    ${USER_KEY}    ${READONLY_CID}   ${S_OID_USER}
                        ...    ELSE IF   "${RUN_TYPE}" == "Simple"    Create List   ${S_OID_USER} 		
                        Get Storagegroup    ${SYSTEM_KEY_IR}    ${READONLY_CID}    ${SG_OID_INV}    ${EMPTY}    @{EXPECTED_OIDS}
                        Run Keyword And Expect Error        *
                        ...  Delete Storagegroup    ${SYSTEM_KEY_IR}    ${READONLY_CID}    ${SG_OID_INV}

    # Get
                            Get object               ${USER_KEY}         ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    s_file_read
                            Get object               ${OTHER_KEY}        ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    s_file_read
                            Get object               ${SYSTEM_KEY_IR}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    s_file_read 
                            Get object               ${SYSTEM_KEY_SN}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    s_file_read

    # Get Range
                            Get Range                           ${USER_KEY}         ${READONLY_CID}    ${S_OID_USER}    s_get_range    ${EMPTY}    0:256
                            Get Range                           ${OTHER_KEY}        ${READONLY_CID}    ${S_OID_USER}    s_get_range    ${EMPTY}    0:256
                            Get Range                           ${SYSTEM_KEY_IR}    ${READONLY_CID}    ${S_OID_USER}    s_get_range    ${EMPTY}    0:256
                            Get Range                           ${SYSTEM_KEY_SN}    ${READONLY_CID}    ${S_OID_USER}    s_get_range    ${EMPTY}    0:256


    # Get Range Hash
                            Get Range Hash                      ${USER_KEY}         ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    0:256
                            Get Range Hash                      ${OTHER_KEY}        ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    0:256
                            Get Range Hash                      ${SYSTEM_KEY_IR}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    0:256
                            Get Range Hash                      ${SYSTEM_KEY_SN}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    0:256

    # Search
    @{S_OBJ_RO} =	        Create List	                        ${S_OID_USER}       ${S_OID_SYS_SN}     
                            Search object                       ${USER_KEY}         ${READONLY_CID}    --root    ${EMPTY}    ${EMPTY}    ${S_OBJ_RO}
                            Search object                       ${OTHER_KEY}        ${READONLY_CID}    --root    ${EMPTY}    ${EMPTY}    ${S_OBJ_RO}
                            Search object                       ${SYSTEM_KEY_IR}    ${READONLY_CID}    --root    ${EMPTY}    ${EMPTY}    ${S_OBJ_RO}
                            Search object                       ${SYSTEM_KEY_SN}    ${READONLY_CID}    --root    ${EMPTY}    ${EMPTY}    ${S_OBJ_RO}

 
    # Head
                            Head object                         ${USER_KEY}         ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    ${EMPTY}
                            Head object                         ${OTHER_KEY}        ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    ${EMPTY}
                            Head object                         ${SYSTEM_KEY_IR}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    ${EMPTY}
                            Head object                         ${SYSTEM_KEY_SN}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}    ${EMPTY}

    # Delete
                            Run Keyword And Expect Error        *       
                            ...  Delete object                  ${OTHER_KEY}        ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}
                            Run Keyword And Expect Error        *  
                            ...  Delete object                  ${SYSTEM_KEY_IR}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}
                            Run Keyword And Expect Error        *  
                            ...  Delete object                  ${SYSTEM_KEY_SN}    ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}
                            Delete object                       ${USER_KEY}         ${READONLY_CID}    ${S_OID_USER}    ${EMPTY}



Cleanup
    @{CLEANUP_FILES} =      Create List	       ${FILE_S}    s_file_read    s_get_range  
                            Cleanup Files      @{CLEANUP_FILES}
                            Get Docker Logs    acl_basic