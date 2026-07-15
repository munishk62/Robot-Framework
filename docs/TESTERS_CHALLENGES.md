# Challenges Faced by WFM Testers

## Locators
- WFM does not have any standard practises when it comes to defining selectors for html elements. 
- The locators change based on configuration for same element in same version of the app.This leads to inconsistencies and difficulties in maintaining tests. 
- data-testid should be used. [Refer recommendation](ASKS_FOR_DEV.md)

## Users & Credentials

- For un controlled environments, like SB, PP getting user credentials is a challenge. 
- Pseudo login is a way & requires some features enabled in kernel. We still need to identify userIds to be used for pseudo login.

## Workflow Changes