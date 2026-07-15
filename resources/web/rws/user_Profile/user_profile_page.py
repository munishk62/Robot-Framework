USER_PROFILE_PAGE_ADD_BUTTON = (
    "//iframe[@id='userProfilesListIframe'] >>> //button[@id='addProfile']"
)
USER_PROFILE_PAGE_PROFILE_ID_TEXTBOX = (
    "//iframe[@id='userProfilesListIframe'] >>> //input[@id='profileId']"
)
USER_PROFILE_PAGE_DESCRIPTION_TEXTBOX = (
    "//iframe[@id='userProfilesListIframe'] >>> //input[@id='description']"
)
USER_PROFILE_PAGE_ORGANIZATION_LEVEL_LIST = (
    "//iframe[@id='userProfilesListIframe'] >>> //select[@id='selectOrganization']"
)
USER_PROFILE_PAGE_SAVE_BUTTON = (
    "//iframe[@id='userProfilesListIframe'] >>> //button[@id='btn_save']"
)
USER_PROFILE_PAGE_USER = "//iframe[@id='userProfilesListIframe'] >>> //td[@id='orgLevelDesc1' and contains(text(),'{organization_level}')]//following::span[contains(text(),'{profile_id}')]"
USER_PROFILE_PAGE_DELETE_ICON = "//iframe[@id='userProfilesListIframe'] >>> //tr/td/span/img[@id='{profile_id}#deleteProfile']"
USER_PROFILE_PAGE_COPY_PERMISSIONS_LIST = (
    "//iframe[@id='userProfilesListIframe'] >>> //select[@id='copyPermissions']"
)
USER_PROFILE_PAGE_USED_FOR_PERMISSIONS_CHECKBOX = (
    "//iframe[@id='userProfilesListIframe'] >>> //input[@id='permission']"
)
USER_PROFILE_PAGE_ASSOCIATED_DEPT_CORP_CHECKBOX = (
    "//iframe[@id='userProfilesListIframe'] >>> (//td[@id='associatedDepartments']//following::input[@id='assDepartment' and @value='CORP' or @value='HEAD'])[1]"
)
USER_PROFILE_PAGE_HEADER_ITEM = "//iframe[@id='userProfilesListIframe'] >>> //td[@class='headerItem']"
USER_PROFILE_PAGE_SPINNER = "//iframe[@id='userProfilesListIframe'] >>> //div[@id='spinner']"
