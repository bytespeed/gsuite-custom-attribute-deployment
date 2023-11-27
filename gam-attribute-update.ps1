# Update the following variables (Note: schema is case sensitive)
$group_email = 'appstream@bytespeed.com'
$schema_federation = 'AppStream_Bytespeed.FederationRole'
$schema_duration = 'AppStream_Bytespeed.SessionDuration'
$federation_role = 'arn:aws:iam::0000:role/appstream,arn:aws:iam::0000:saml-provider/sso'
$SessionDuration = '10800'

#Update user command
gam print group-members group $group_email fields email | gam csv - gam update user '~email' $schema_federation $federation_role $schema_duration $SessionDuration
"`n"
Read-Host -Prompt "Press Enter to exit"