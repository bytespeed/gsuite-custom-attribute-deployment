# Update the following variables (Note: schema is case sensative)
$group_email = 'appstream@bytespeed.com'
$schema = 'AppStream_Bytespeed.FederationRole'
$federation_role = 'arn:aws:iam::0000:role/appstream,arn:aws:iam::0000:saml-provider/sso'

#Update user command
gam print group-members group $group_email fields email | gam csv - gam update user '~email' $schema $federation_role
"`n"
Read-Host -Prompt "Press Enter to exit"