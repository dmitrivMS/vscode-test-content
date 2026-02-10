<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UserProfile.ascx.cs" Inherits="WebApp.Controls.UserProfile" %>

<div class="user-profile-card">
    <asp:Image ID="imgAvatar" runat="server" CssClass="avatar" />
    <h3>
        <asp:Label ID="lblDisplayName" runat="server" />
    </h3>
    <p class="email">
        <asp:HyperLink ID="lnkEmail" runat="server" />
    </p>
    <asp:Panel ID="pnlBio" runat="server" CssClass="bio-section">
        <asp:Literal ID="litBio" runat="server" />
    </asp:Panel>
    <asp:Button ID="btnEditProfile" runat="server" Text="Edit Profile"
        CssClass="btn btn-primary" OnClick="btnEditProfile_Click" />
</div>
