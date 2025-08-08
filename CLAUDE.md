Implement this the topic of this document in Terraform.  it should be a single module that provisions across 3 cloud accounts, 2 aws and 1 azure.  Use the 'profile' argument for the AWS providers.  One profile is 'aws-commercial'.  The 2nd is 'aws-govcloud'.  The nickname of the azure account is 'azure-identity-provider' or 'azure-id' for short.  Hardcode the provider profiles.  Do not pass in variables unless necessary and useful, favoring hardcoded values.

Assume credentials are configured outside of Terraform and automatically available.

implement as much as is possible using the standard aws and azurerm providers.  do not use other providers.

Do not script or implement the step by step instructions when it can be accomplished in terraform. Use terraform provisioners with a python script for things that makes sense for.  Write a separate python script for any remaining items.  At the end, the entire process should be fully automated.  Address the entire lifecycle - both setup and teardown, clearly labeling each piece that is not implemented purely in terraform

# Configure SAML and SCIM with Microsoft Entra ID and IAM Identity Center - AWS IAM Identity Center

# 

Configure SAML and SCIM with Microsoft Entra ID and IAM Identity Center

[PDF](/pdfs/singlesignon/latest/userguide/sso-ug.pdf#idp-microsoft-entra)

[RSS](iam-identity-center-user-guide-doc-history.rss)

Focus mode

![No results found](/assets/r/images/summary.svg)[Summarize page](#)

Configure SAML and SCIM with Microsoft Entra ID and IAM Identity Center - AWS IAM Identity Center

AWS IAM Identity Center supports integration with [Security Assertion Markup Language (SAML) 2.0](./scim-profile-saml.html) as well as [automatic provisioning](./provision-automatically.html) (synchronization) of user and group information from Microsoft Entra ID (formerly known as Azure Active Directory or Azure AD) into IAM Identity Center using the [System for Cross-domain Identity Management (SCIM) 2.0](./scim-profile-saml.html#scim-profile) protocol. For more information, see [Using SAML and SCIM identity federation with external identity providers](./other-idps.html).

**Objective**

In this tutorial, you will set up a test lab and configure a SAML connection and SCIM provisioning between Microsoft Entra ID and IAM Identity Center. During the initial preparation steps, you'll create a test user (Nikki Wolf) in both Microsoft Entra ID and IAM Identity Center which you'll use to test the SAML connection in both directions. Later, as part of the SCIM steps, you'll create a different test user (Richard Roe) to verify that new attributes in Microsoft Entra ID are synchronizing to IAM Identity Center as expected.

## Considerations

The following are important considerations about Microsoft Entra ID that can affect how you plan to implement [automatic provisioning]with IAM Identity Center in your production environment using the SCIM v2 protocol.


## Step 1: Prepare your Microsoft tenant

In this step, you will walk through how to install and configure your AWS IAM Identity Center enterprise application and assign access to a newly created Microsoft Entra ID test user.

Step 1.1 >

**Step 1.1: Set up the AWS IAM Identity Center enterprise application in Microsoft Entra ID**

In this procedure, you install the AWS IAM Identity Center enterprise application in Microsoft Entra ID. You will need this application later to configure your SAML connection with AWS.

1.  Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com/) as at least a Cloud Application Administrator.

2.  Navigate to **Identity > Applications > Enterprise applications**, and then choose **New application**.

3.  On the **Browse Microsoft Entra Gallery** page, enter **`AWS IAM Identity Center`** in the search box.

4.  Select **AWS IAM Identity Center** from the results.

5.  Choose **Create**.


Step 1.2 >

**Step 1.2: Create a test user in Microsoft Entra ID**

Nikki Wolf is the name of your Microsoft Entra ID test user that you will create in this procedure.

1.  In the [Microsoft Entra admin center](https://entra.microsoft.com/) console, navigate to **Identity > Users > All users**.

2.  Select **New user**, and then choose **Create new user** at the top of the screen.

3.  In **User principal name**, enter **`NikkiWolf`**, and then select your preferred domain and extension. For example, _NikkiWolf_@`example.org`.

4.  In **Display name**, enter **`NikkiWolf`**.

5.  In **Password**, enter a strong password or select the eye icon to show the password that was auto-generated, and either copy or write down the value that's displayed.

6.  Choose **Properties**, in **First name**, enter **`Nikki`**. In **Last name**, enter **`Wolf`**.

7.  Choose **Review + create**, and then choose **Create**.


Step 1.3

**Step 1.3: Test Nikki's experience prior to assigning her permissions to AWS IAM Identity Center**

In this procedure, you will verify what Nikki can successfully sign into her Microsoft [My Account portal](https://myaccount.microsoft.com/).

1.  In the same browser, open a new tab, go to the [My Account portal](https://myaccount.microsoft.com/) sign-in page, and enter Nikki's full email address. For example, _NikkiWolf_@`example.org`.

2.  When prompted, enter Nikki's password, and then choose **Sign in**. If this was an auto-generated password, you will be prompted to change the password.

3.  On the **Action Required** page, choose **Ask later** to bypass the prompt for additional security methods.

4.  On the **My account** page, in the left navigation pane, choose **My Apps**. Notice that besides **Add-ins**, no apps are displayed at this time. You'll add an **AWS IAM Identity Center** app that will appear here in a later step.


Step 1.4

**Step 1.4: Assign permissions to Nikki in Microsoft Entra ID**

Now that you have verified that Nikki can successfully access the **My account portal**, use this procedure to assign her user to the **AWS IAM Identity Center** app.

1.  In the [Microsoft Entra admin center](https://entra.microsoft.com/) console, navigate to **Identity > Applications > Enterprise applications** and then choose **AWS IAM Identity Center** from the list.

2.  On the left, choose **Users and groups**.

3.  Choose **Add user/group**. You can ignore the message stating that groups are not available for assignment. This tutorial does not use groups for assignments.

4.  On the **Add Assignment** page, under **Users**, choose **None Selected**.

5.  Select **NikkiWolf**, and then choose **Select**.

6.  On the **Add Assignment** page, choose **Assign**. NikkiWolf now appears in the list of users who are assigned to the **AWS IAM Identity Center** app.


**Step 1.1: Set up the AWS IAM Identity Center enterprise application in Microsoft Entra ID**

In this procedure, you install the AWS IAM Identity Center enterprise application in Microsoft Entra ID. You will need this application later to configure your SAML connection with AWS.

1.  Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com/) as at least a Cloud Application Administrator.

2.  Navigate to **Identity > Applications > Enterprise applications**, and then choose **New application**.

3.  On the **Browse Microsoft Entra Gallery** page, enter **`AWS IAM Identity Center`** in the search box.

4.  Select **AWS IAM Identity Center** from the results.

5.  Choose **Create**.


## Step 2: Prepare your AWS account

In this step, you'll walk through how to use **IAM Identity Center** to configure access permissions (via permission set), manually create a corresponding Nikki Wolf user, and assign her the necessary permissions to administer resources in AWS.

Step 2.1 >

**Step 2.1: Create a RegionalAdmin permission set in IAM Identity Center**

This permission set will be used to grant Nikki the necessary AWS account permissions required to manage Regions from the **Account** page within the AWS Management Console. All other permissions to view or manage any other information for Nikki's account is denied by default.

1.  Open the [IAM Identity Center console](https://console.aws.amazon.com/singlesignon).

2.  Under **Multi-account permissions**, choose **Permission sets**.

3.  Choose **Create permission set**.

4.  On the **Select permission set type** page, select **Custom permission set**, and then choose **Next**.

5.  Select **Inline policy** to expand it, and then create a policy for the permission set using the following steps:

    1.  Choose **Add new statement** to create a policy statement.

    2.  Under **Edit statement**, select **Account** from the list, and then choose the following checkboxes.

        -   **`ListRegions`**

        -   **`GetRegionOptStatus`**

        -   **`DisableRegion`**

        -   **`EnableRegion`**


    3.  Next to **Add a resource**, choose **Add**.
        
    4.  On the **Add resource** page, under **Resource type**, select **All Resources**, and then choose **Add resource**. Verify that your policy looks like the following:
        
        `{     "Statement": [         {             "Sid": "Statement1",             "Effect": "Allow",             "Action": [                 "account:ListRegions",                 "account:DisableRegion",                 "account:EnableRegion",                 "account:GetRegionOptStatus"             ],             "Resource": [                 "*"             ]         }     ] }`

6.  Choose **Next**.

7.  On the **Specify permission set details** page, under **Permission set name**, enter **`RegionalAdmin`**, and then choose **Next**.

8.  On the **Review and create** page, choose **Create**. You should see **RegionalAdmin** displayed in the list of permission sets.


Step 2.2 >

**Step 2.2: Create a corresponding NikkiWolf user in IAM Identity Center**

Since the SAML protocol does not provide a mechanism to query the IdP (Microsoft Entra ID) and automatically create users here in IAM Identity Center, use the following procedure to manually create a user in IAM Identity Center that mirrors the core attributes from Nikki Wolfs user in Microsoft Entra ID.


Step 2.3

**Step 2.3: Assign Nikki to the RegionalAdmin permission set in IAM Identity Center**

Here you locate the AWS account in which Nikki will administer Regions, and then assign the necessary permissions required for her to successfully access the AWS access portal.

**Step 2.1: Create a RegionalAdmin permission set in IAM Identity Center**

This permission set will be used to grant Nikki the necessary AWS account permissions required to manage Regions from the **Account** page within the AWS Management Console. All other permissions to view or manage any other information for Nikki's account is denied by default.

        
    4.  On the **Add resource** page, under **Resource type**, select **All Resources**, and then choose **Add resource**. Verify that your policy looks like the following:
        
        `{     "Statement": [         {             "Sid": "Statement1",             "Effect": "Allow",             "Action": [                 "account:ListRegions",                 "account:DisableRegion",                 "account:EnableRegion",                 "account:GetRegionOptStatus"             ],             "Resource": [                 "*"             ]         }     ] }`

6.  Choose **Next**.

7.  On the **Specify permission set details** page, under **Permission set name**, enter **`RegionalAdmin`**, and then choose **Next**.

8.  On the **Review and create** page, choose **Create**. You should see **RegionalAdmin** displayed in the list of permission sets.


## Step 3: Configure and test your SAML connection

In this step, you configure your SAML connection using the AWS IAM Identity Center enterprise application in Microsoft Entra ID together with the external IdP settings in IAM Identity Center.

Step 3.1 >

**Step 3.1: Collect required service provider metadata from IAM Identity Center**

In this step, you will launch the **Change identity source** wizard from within the IAM Identity Center console and retrieve the metadata file and the AWS specific sign-in URL you'll need to enter when configuring the connection with Microsoft Entra ID in the next step.

1.  In the [IAM Identity Center console](https://console.aws.amazon.com/singlesignon), choose **Settings**.

2.  On the **Settings** page, choose the **Identity source** tab, and then choose **Actions > Change identity source**.

3.  On the **Choose identity source** page, select **External identity provider**, and then choose **Next**.

4.  On the **Configure external identity provider** page, under **Service provider metadata**, choose **Download metadata file** to download the XML file.

5.  In the same section, locate the **AWS access portal sign-in URL** value and copy it. You will need to enter this value when prompted in the next step.

6.  Leave this page open, and move to the next step (**`Step 3.2`**) to configure the AWS IAM Identity Center enterprise application in Microsoft Entra ID. Later, you'll return to this page to complete the process.


Step 3.2 >

**Step 3.2: Configure the AWS IAM Identity Center enterprise application in Microsoft Entra ID**

This procedure establishes one-half of the SAML connection on the Microsoft side using the values from the metadata file and Sign-On URL you obtained in the last step.

1.  In the [Microsoft Entra admin center](https://entra.microsoft.com/) console, navigate to **Identity > Applications > Enterprise applications** and then choose **AWS IAM Identity Center**.

2.  On the left, choose **2\. Set up Single sign-on**.

3.  On the **Set up Single Sign-On with SAML** page, choose **SAML**. Then choose **Upload metadata file**, choose the folder icon, select the service provider metadata file that you downloaded in the previous step, and then choose **Add**.

4.  On the **Basic SAML Configuration** page, verify that both the **Identifier** and **Reply URL** values now point to endpoints in AWS that start with ``https://`<REGION>`.signin.aws.amazon.com/platform/saml/``.

5.  Under **Sign on URL (Optional)**, paste in the **AWS access portal sign-in URL** value you copied in the previous step (**`Step 3.1`**), choose **Save**, and then choose **X** to close the window.

6.  If prompted to test single sign-on with AWS IAM Identity Center, choose **No I'll test later**. You will do this verification in a later step.

7.  On the **Set up Single Sign-On with SAML** page, in the **SAML Certificates** section, next to **Federation Metadata XML**, choose **Download** to save the metadata file to your system. You will need to upload this file when prompted in the next step.


Step 3.3 >

**Step 3.3: Configure the Microsoft Entra ID external IdP in AWS IAM Identity Center**

Here you will return to the **Change identity source** wizard in the IAM Identity Center console to complete the second-half of the SAML connection in AWS.

1.  Return to the browser session you left open from **`Step 3.1`** in the IAM Identity Center console.

2.  On the **Configure external identity provider** page, in the **Identity provider metadata** section, under **IdP SAML metadata**, choose the **Choose file** button, and select the identity provider metadata file that you downloaded from Microsoft Entra ID in the previous step, and then choose **Open**.

3.  Choose **Next**.

4.  After you read the disclaimer and are ready to proceed, enter **`ACCEPT`**.

5.  Choose **Change identity source** to apply your changes.


Step 3.4 >

**Step 3.4: Test that Nikki is redirected to the AWS access portal**

In this procedure, you will test the SAML connection by signing in to Microsoft's **My Account portal** with Nikki's credentials. Once authenticated, you'll select the AWS IAM Identity Center application which will redirect Nikki to the AWS access portal.

1.  Go to the [My Account portal](https://myaccount.microsoft.com/) sign in page, and enter Nikki's full email address. For example, _`NikkiWolf`@_`example.org`.

2.  When prompted, enter Nikki's password, and then choose **Sign in**.

3.  On the **My account** page, in the left navigation pane, choose **My Apps**.

4.  On the **My Apps** page, select the app named **AWS IAM Identity Center**. This should prompt you for additional authentication.

5.  On Microsoft's sign in page, choose your NikkiWolf credentials. If prompted a second time for authentication, choose your NikkiWolf credentials again. This should automatically redirect you to the AWS access portal.

    ###### Tip

    If you are not redirected successfully, check to make sure the **AWS access portal sign-in URL** value you entered in **`Step 3.2`** matches the value you copied from **`Step 3.1`**.

6.  Verify that your AWS accounts display.

    ###### Tip

    If the page is empty and no AWS accounts display, confirm that Nikki was successfully assigned to the **RegionalAdmin** permission set (see **`Step 2.3`**).



###### Nicely done!

Steps 1 through 3 helped you to successfully implement and test your SAML connection. Now, to complete the tutorial, we encourage you to move on to Step 4 to implement automatic provisioning.


**Step 3.1: Collect required service provider metadata from IAM Identity Center**

In this step, you will launch the **Change identity source** wizard from within the IAM Identity Center console and retrieve the metadata file and the AWS specific sign-in URL you'll need to enter when configuring the connection with Microsoft Entra ID in the next step.

1.  In the [IAM Identity Center console](https://console.aws.amazon.com/singlesignon), choose **Settings**.

2.  On the **Settings** page, choose the **Identity source** tab, and then choose **Actions > Change identity source**.

3.  On the **Choose identity source** page, select **External identity provider**, and then choose **Next**.

4.  On the **Configure external identity provider** page, under **Service provider metadata**, choose **Download metadata file** to download the XML file.

5.  In the same section, locate the **AWS access portal sign-in URL** value and copy it. You will need to enter this value when prompted in the next step.

6.  Leave this page open, and move to the next step (**`Step 3.2`**) to configure the AWS IAM Identity Center enterprise application in Microsoft Entra ID. Later, you'll return to this page to complete the process.


## Step 4: Configure and test your SCIM synchronization

In this step, you will set up [automatic provisioning](./provision-automatically.html) (synchronization) of user information from Microsoft Entra ID into IAM Identity Center using the SCIM v2.0 protocol. You configure this connection in Microsoft Entra ID using your SCIM endpoint for IAM Identity Center and a bearer token that is created automatically by IAM Identity Center.

When you configure SCIM synchronization, you create a mapping of your user attributes in Microsoft Entra ID to the named attributes in IAM Identity Center. This causes the expected attributes to match between IAM Identity Center and Microsoft Entra ID.

The following steps walk you through how to enable automatic provisioning of users that primarily reside in Microsoft Entra ID to IAM Identity Center using the IAM Identity Center app in Microsoft Entra ID.

Step 4.1 >

**Step 4.1: Create a second test user in Microsoft Entra ID**

For testing purposes, you will create a new user (Richard Roe) in Microsoft Entra ID. Later, after you set up SCIM synchronization, you will test that this user and all relevant attributes were synced successfully to IAM Identity Center.

1.  In the [Microsoft Entra admin center](https://entra.microsoft.com/) console, navigate to **Identity > Users > All users**.

2.  Select **New user**, and then choose **Create new user** at the top of the screen.

3.  In **User principal name**, enter **`RichRoe`**, and then select your preferred domain and extension. For example, _RichRoe_@`example.org`.


7.  Choose **Review + create**, and then choose **Create**.


Step 4.2 >

**Step 4.2: Enable automatic provisioning in IAM Identity Center**

In this procedure, you will use the IAM Identity Center console to enable automatic provisioning of users and groups coming from Microsoft Entra ID into IAM Identity Center.

1.  Open the [IAM Identity Center console](https://console.aws.amazon.com/singlesignon), and choose **Settings** in the left navigation pane.

2.  On the **Settings** page, under the **Identity source** tab, notice that **Provisioning method** is set to **Manual**.

3.  Locate the **Automatic provisioning** information box, and then choose **Enable**. This immediately enables automatic provisioning in IAM Identity Center and displays the necessary SCIM endpoint and access token information.

4.  In the **Inbound automatic provisioning** dialog box, copy each of the values for the following options. You will need to paste these in the next step when you configure provisioning in Microsoft Entra ID.

    1.  **SCIM endpoint** - For example, https://scim.`us-east-2`.amazonaws.com/`11111111111-2222-3333-4444-555555555555`/scim/v2

    2.  **Access token** - Choose **Show token** to copy the value.


    ###### Warning
    
    This is the only time where you can obtain the SCIM endpoint and access token. Ensure you copy these values before moving forward.

5.  Choose **Close**.

6.  Under the **Identity source** tab, notice that **Provisioning method** is now set to **SCIM**.


Step 4.3 >

**Step 4.3: Configure automatic provisioning in Microsoft Entra ID**

Now that you have your RichRoe test user in place and have enabled SCIM in IAM Identity Center, you can proceed with configuring the SCIM synchronization settings in Microsoft Entra ID.

1.  In the [Microsoft Entra admin center](https://entra.microsoft.com/) console, navigate to **Identity > Applications > Enterprise applications** and then choose **AWS IAM Identity Center**.

2.  Choose **Provisioning**, under **Manage**, choose **Provisioning** again.

3.  In **Provisioning Mode** select **Automatic**.

4.  Under **Admin Credentials**, in **Tenant URL** paste in the **SCIM endpoint** URL value you copied earlier in **`Step 4.2`**. In **Secret Token**, paste in the **Access token** value.

5.  Choose **Test Connection**. You should see a message indicating that the tested credentials were successfully authorized to enable provisioning.

6.  Choose **Save**.

7.  Under **Manage**, choose **Users and groups**, and then choose **Add user/group**.

8.  On the **Add Assignment** page, under **Users**, choose **None Selected**.

9.  Select **RichRoe**, and then choose **Select**.

10.  On the **Add Assignment** page, choose **Assign**.

11.  Choose **Overview**, and then choose **Start provisioning**.


Step 4.4

**Step 4.4: Verify that synchronization occurred**

In this section, you will verify that Richard's user was successfully provisioned and that all attributes are displayed in IAM Identity Center.

1.  In the [IAM Identity Center console](https://console.aws.amazon.com/singlesignon), choose **Users**.

2.  On the **Users** page, you should see your **RichRoe** user displayed. Notice that in the **Created by** column the value is set to **SCIM**.

###### Congratulations!

You have successfully set up a SAML connection between Microsoft and AWS and have verified that automatic provisioning is working to keep everything in sync. Now you can apply what you've learned to more smoothly set up your production environment.


## Step 5: Configure ABAC - _Optional_

Now that you have successfully configured SAML and SCIM, you can optionally choose to configure attribute-based access control (ABAC). ABAC is an authorization strategy that defines permissions based on attributes.

With Microsoft Entra ID, you can use either of the following two methods to configure ABAC for use with IAM Identity Center.

Configure user attributes in Microsoft Entra ID for access control in IAM Identity Center

**Configure user attributes in Microsoft Entra ID for access control in IAM Identity Center**

In the following procedure, you will determine which attributes in Microsoft Entra ID should be used by IAM Identity Center to manage access to your AWS resources. Once defined, Microsoft Entra ID sends these attributes to IAM Identity Center through SAML assertions. You will then need to [Create a permission set](./howtocreatepermissionset.html) in IAM Identity Center to manage access based on the attributes you passed from Microsoft Entra ID.

Before you begin this procedure, you first need to enable the [Attributes for access control](./attributesforaccesscontrol.html) feature. For more information about how to do this, see [Enable and configure attributes for access control](./configure-abac.html).

1.  In the [Microsoft Entra admin center](https://entra.microsoft.com/) console, navigate to **Identity > Applications > Enterprise applications** and then choose **AWS IAM Identity Center**.

2.  Choose **Single sign-on**.

3.  In the **Attributes & Claims** section, choose **Edit**.

4.  On the **Attributes & Claims** page, do the following:

    1.  Choose **Add new claim**

    2.  For **Name**, enter `` AccessControl:`AttributeName` ``. Replace `AttributeName` with the name of the attribute you are expecting in IAM Identity Center. For example, `AccessControl:**Department**`.

    3.  For **Namespace**, enter **`https://aws.amazon.com/SAML/Attributes`**.

    4.  For **Source**, choose **Attribute**.

    5.  For **Source attribute**, use the drop-down list to choose the Microsoft Entra ID user attributes. For example, `user.**department**`.

5.  Repeat the previous step for each attribute you need to send to IAM Identity Center in the SAML assertion.

6.  Choose **Save**.


Configure ABAC using IAM Identity Center

**Configure ABAC using IAM Identity Center**

With this method, you use the [Attributes for access control](./attributesforaccesscontrol.html) feature in IAM Identity Center to pass an `Attribute` element with the `Name` attribute set to `` https://aws.amazon.com/SAML/Attributes/AccessControl:`{TagKey}` ``. You can use this element to pass attributes as session tags in the SAML assertion. For more information about session tags, see [Passing session tags in AWS STS](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_session-tags.html) in the _IAM User Guide_.

To pass attributes as session tags, include the `AttributeValue` element that specifies the value of the tag. For example, to pass the tag key-value pair `Department=billing`, use the following attribute:

`<saml:AttributeStatement> <saml:Attribute Name="https://aws.amazon.com/SAML/Attributes/AccessControl:Department"> <saml:AttributeValue>billing </saml:AttributeValue> </saml:Attribute> </saml:AttributeStatement>`

If you need to add multiple attributes, include a separate `Attribute` element for each tag.



-   Configure user attributes in Microsoft Entra ID for access control in IAM Identity Center

-   Configure ABAC using IAM Identity Center


**Configure user attributes in Microsoft Entra ID for access control in IAM Identity Center**

In the following procedure, you will determine which attributes in Microsoft Entra ID should be used by IAM Identity Center to manage access to your AWS resources. Once defined, Microsoft Entra ID sends these attributes to IAM Identity Center through SAML assertions. You will then need to [Create a permission set](./howtocreatepermissionset.html) in IAM Identity Center to manage access based on the attributes you passed from Microsoft Entra ID.

Before you begin this procedure, you first need to enable the [Attributes for access control](./attributesforaccesscontrol.html) feature. For more information about how to do this, see [Enable and configure attributes for access control](./configure-abac.html).

1.  In the [Microsoft Entra admin center](https://entra.microsoft.com/) console, navigate to **Identity > Applications > Enterprise applications** and then choose **AWS IAM Identity Center**.

2.  Choose **Single sign-on**.

3.  In the **Attributes & Claims** section, choose **Edit**.

4.  On the **Attributes & Claims** page, do the following:

    1.  Choose **Add new claim**

    2.  For **Name**, enter `` AccessControl:`AttributeName` ``. Replace `AttributeName` with the name of the attribute you are expecting in IAM Identity Center. For example, `AccessControl:**Department**`.

    3.  For **Namespace**, enter **`https://aws.amazon.com/SAML/Attributes`**.

    4.  For **Source**, choose **Attribute**.

    5.  For **Source attribute**, use the drop-down list to choose the Microsoft Entra ID user attributes. For example, `user.**department**`.

5.  Repeat the previous step for each attribute you need to send to IAM Identity Center in the SAML assertion.

6.  Choose **Save**.


## Assign access to AWS accounts

The following steps are only required to grant access to AWS accounts only. These steps are not required to grant access to AWS applications.

###### Note

To complete this step, you'll need an Organization instance of IAM Identity Center. For more information, see [Organization and account instances of IAM Identity Center](./identity-center-instances.html).

### Step 1: IAM Identity Center: Grant Microsoft Entra ID users access to accounts

1.  Return to the **IAM Identity Center** console. In the IAM Identity Center navigation pane, under **Multi-account permissions**, choose **AWS accounts**.

2.  On the **AWS accounts** page the **Organizational structure** displays your organizational root with your accounts underneath it in the hierarchy. Select the checkbox for your management account, then select **Assign users or groups**.

3.  The **Assign users and groups** workflow displays. It consists of three steps:

    1.  For **Step 1: Select users and groups** choose the user that will be performing the administrator job function. Then choose **Next**.

    2.  For **Step 2: Select permission sets** choose **Create permission set** to open a new tab that steps you through the three sub-steps involved in creating a permission set.

        1.  For **Step 1: Select permission set type** complete the following:

            -   In **Permission set type**, choose **Predefined permission set**.

            -   In **Policy for predefined permission set**, choose **AdministratorAccess**.


            Choose **Next**.
            
        2.  For **Step 2: Specify permission set details**, keep the default settings, and choose **Next**.
            
            The default settings create a permission set named `AdministratorAccess` with session duration set to one hour.
            
        3.  For **Step 3: Review and create**, verify that the **Permission set type** uses the AWS managed policy **AdministratorAccess**. Choose **Create**. On the **Permission sets** page a notification appears informing you that the permission set was created. You can close this tab in your web browser now.
            
        4.  On the **Assign users and groups** browser tab, you are still on **Step 2: Select permission sets** from which you started the create permission set workflow.
            
        5.  In the **Permissions sets** area, choose the **Refresh** button. The `AdministratorAccess` permission set you created appears in the list. Select the checkbox for that permission set and then choose **Next**.
            
    3.  For **Step 3: Review and submit** review the selected user and permission set, then choose **Submit**.
        
        The page updates with a message that your AWS account is being configured. Wait until the process completes.
        
        You are returned to the AWS accounts page. A notification message informs you that your AWS account has been reprovisioned and the updated permission set applied. When the user sign in they will have the option of choosing the `AdministratorAccess` role.


### Step 2: Microsoft Entra ID: Confirm Microsoft Entra ID users access to AWS resources

1.  Return to the **Microsoft Entra ID** console and navigate to your IAM Identity Center SAML-based Sign-on application.

2.  Select **Users and groups** and select **Add users or groups**. You’ll add the user you created in this tutorial in Step 4 to the Microsoft Entra ID application. By adding the user, you’ll allow them to sign-in to AWS. Search for the user you created at Step 4. If you followed this step, it would be `RichardRoe`.

    1.  For a demo, see [Federate your existing IAM Identity Center instance with Microsoft Entra ID](https://youtu.be/iSCuTJNeN6c?si=29HSAK8DgBEhSVad)


## Troubleshooting

For general SCIM and SAML troubleshooting with Microsoft Entra ID, see the following sections:

-   [Synchronization issues with Microsoft Entra ID and IAM Identity Center](#entra-scim-troubleshooting)

-   [Specific users fail to synchronize into IAM Identity Center from an external SCIM provider](./troubleshooting.html#issue2)

-   [Issues regarding contents of SAML assertions created by IAM Identity Center](./troubleshooting.html#issue1)

-   [Duplicate user or group error when provisioning users or groups with an external identity provider](./troubleshooting.html#duplicate-user-group-idp)

-   [Additional resources](#entra-scim-troubleshooting-resources)


### Synchronization issues with Microsoft Entra ID and IAM Identity Center

If you are experiencing issues with Microsoft Entra ID users not synchronizing to IAM Identity Center, it might be due to a syntax issue that IAM Identity Center has flagged when a new user is being added to IAM Identity Center. You can confirm this by checking the Microsoft Entra ID audit logs for failed events, such as an `'Export'`. The **Status Reason** for this event will state:

`{"schema":["urn:ietf:params:scim:api:messages:2.0:Error"],"detail":"Request is unparsable, syntactically incorrect, or violates schema.","status":"400"}`

You can also check AWS CloudTrail for the failed event. This can be done by searching in the **Event History** console of CloudTrail using the following filter:

`"eventName":"CreateUser"`

The error in the CloudTrail event will state the following:

`"errorCode": "ValidationException",         "errorMessage": "Currently list attributes only allow single item“`

Ultimately, this exception means that one of the values passed from Microsoft Entra ID contained more values than anticipated. The solution is to review the attributes of the user in Microsoft Entra ID, ensuring that none contain duplicate values. One common example of duplicate values is having multiple values present for contact numbers such as **mobile**, **work**, and **fax**. Although separate values, they are all passed to IAM Identity Center under the single parent attribute **phoneNumbers**.

For general SCIM troubleshooting tips, see [Troubleshooting](./troubleshooting.html#issue2).

### Microsoft Entra ID Guest Account Synchronization

If you would like to sync your Microsoft Entra ID guest users to IAM Identity Center, see the following procedure.

Microsoft Entra ID guest users’ email is different than Microsoft Entra ID users. This difference causes issues when attempting to synchronize Microsoft Entra ID guest users with IAM Identity Center. For example, see the following email address for a guest user:

``exampleuser_domain.com#`EXT@domain.onmicrosoft.com`.``

IAM Identity Center expects the email address of a user to not contain the `EXT@domain` format.

1.  Sign in to the [Microsoft Entra admin center](https://entra.microsoft.com/) and navigate to **Identity** > **Applications** > **Enterprise applications** and then choose **AWS IAM Identity Center**

2.  Navigate to the **Single Sign On** tab in the left pane.

3.  Select **Edit** which appears next to **User Attributes & Claims**.

4.  Select **Unique User Identifier (Name ID)** following **Required Claims**.

5.  You will create two claim conditions for your Microsoft Entra ID users and guest users:

    1.  For Microsoft Entra ID users, create a user type for members with source attribute set to `user.userprincipalname`.

    2.  For Microsoft Entra ID guest users, create a user type for external guests with the source attribute set to `user.mail`.

    3.  Select **Save** and retry signing in as a Microsoft Entra ID guest user.


### Additional resources

-   For general SCIM troubleshooting tips, see [Troubleshooting IAM Identity Center issues](./troubleshooting.html).

-   For Microsoft Entra ID troubleshooting, see [Microsoft documentation](https://learn.microsoft.com/en-us/entra/identity/saas-apps/aws-single-sign-on-provisioning-tutorial#troubleshooting-tips).

-   To learn more about federation across multiple AWS accounts, see [Securing AWS accounts with Azure Active Directory Federation](https://aws.amazon.com/blogs/apn/securing-aws-accounts-with-azure-active-directory-federation/).

