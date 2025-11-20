<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="TaskManager.Web.Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Contoso Task Manager</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 800px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            padding: 30px;
        }
        
        h1 {
            color: #333;
            margin-bottom: 10px;
            font-size: 32px;
        }
        
        .subtitle {
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }
        
        .info-panel {
            background: #f8f9fa;
            border-left: 4px solid #667eea;
            padding: 15px;
            margin-bottom: 30px;
            border-radius: 4px;
        }
        
        .info-panel h3 {
            color: #333;
            margin-bottom: 10px;
            font-size: 16px;
        }
        
        .info-panel p {
            color: #666;
            font-size: 14px;
            line-height: 1.6;
        }
        
        .info-panel .server-info {
            margin-top: 10px;
            padding-top: 10px;
            border-top: 1px solid #ddd;
            font-family: 'Courier New', monospace;
            font-size: 12px;
            color: #667eea;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        label {
            display: block;
            color: #333;
            font-weight: 600;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        input[type="text"],
        textarea {
            width: 100%;
            padding: 12px;
            border: 2px solid #e1e4e8;
            border-radius: 6px;
            font-size: 14px;
            font-family: inherit;
            transition: border-color 0.3s;
        }
        
        input[type="text"]:focus,
        textarea:focus {
            outline: none;
            border-color: #667eea;
        }
        
        textarea {
            resize: vertical;
            min-height: 80px;
        }
        
        .button-group {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
        
        .btn {
            padding: 12px 24px;
            border: none;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: #667eea;
            color: white;
        }
        
        .btn-primary:hover {
            background: #5568d3;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
        }
        
        .btn-secondary {
            background: #6c757d;
            color: white;
        }
        
        .btn-secondary:hover {
            background: #5a6268;
        }
        
        .tasks-grid {
            margin-top: 30px;
        }
        
        .tasks-grid h2 {
            color: #333;
            margin-bottom: 15px;
            font-size: 20px;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }
        
        table thead {
            background: #f8f9fa;
        }
        
        table th {
            padding: 12px;
            text-align: left;
            font-weight: 600;
            color: #333;
            border-bottom: 2px solid #dee2e6;
            font-size: 14px;
        }
        
        table td {
            padding: 12px;
            border-bottom: 1px solid #dee2e6;
            color: #666;
            font-size: 14px;
        }
        
        table tr:hover {
            background: #f8f9fa;
        }
        
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
        }
        
        .status-pending {
            background: #fff3cd;
            color: #856404;
        }
        
        .status-completed {
            background: #d4edda;
            color: #155724;
        }
        
        .message {
            padding: 12px;
            margin-bottom: 20px;
            border-radius: 6px;
            font-size: 14px;
        }
        
        .message-success {
            background: #d4edda;
            border: 1px solid #c3e6cb;
            color: #155724;
        }
        
        .message-error {
            background: #f8d7da;
            border: 1px solid #f5c6cb;
            color: #721c24;
        }
        
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }
        
        .stat-card h3 {
            font-size: 32px;
            margin-bottom: 5px;
        }
        
        .stat-card p {
            font-size: 14px;
            opacity: 0.9;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h1>🚀 Contoso Task Manager</h1>
            <p class="subtitle">High-Availability Web Application - Azure Specialization Demo</p>
            
            <div class="info-panel">
                <h3>📊 Application Information</h3>
                <p><strong>Purpose:</strong> Demonstration application for Azure Infrastructure and Database Migration Specialization audit preparation.</p>
                <p><strong>Architecture:</strong> Load-balanced IIS servers with Azure SQL Database backend</p>
                <p><strong>SLA Target:</strong> 99.99% availability</p>
                <div class="server-info">
                    <strong>Server:</strong> <asp:Label ID="lblServerName" runat="server"></asp:Label><br />
                    <strong>Database:</strong> <asp:Label ID="lblDatabaseStatus" runat="server"></asp:Label>
                </div>
            </div>
            
            <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                <div class="message message-success">
                    <asp:Label ID="lblMessage" runat="server"></asp:Label>
                </div>
            </asp:Panel>
            
            <asp:Panel ID="pnlError" runat="server" Visible="false">
                <div class="message message-error">
                    <asp:Label ID="lblError" runat="server"></asp:Label>
                </div>
            </asp:Panel>
            
            <div class="stats">
                <div class="stat-card">
                    <h3><asp:Label ID="lblTotalTasks" runat="server">0</asp:Label></h3>
                    <p>Total Tasks</p>
                </div>
                <div class="stat-card">
                    <h3><asp:Label ID="lblCompletedTasks" runat="server">0</asp:Label></h3>
                    <p>Completed</p>
                </div>
                <div class="stat-card">
                    <h3><asp:Label ID="lblPendingTasks" runat="server">0</asp:Label></h3>
                    <p>Pending</p>
                </div>
            </div>
            
            <div class="form-group">
                <label for="txtTaskTitle">Task Title</label>
                <asp:TextBox ID="txtTaskTitle" runat="server" placeholder="Enter task title"></asp:TextBox>
            </div>
            
            <div class="form-group">
                <label for="txtTaskDescription">Task Description</label>
                <asp:TextBox ID="txtTaskDescription" runat="server" TextMode="MultiLine" 
                    placeholder="Enter task description"></asp:TextBox>
            </div>
            
            <div class="button-group">
                <asp:Button ID="btnAddTask" runat="server" Text="➕ Add Task" 
                    CssClass="btn btn-primary" OnClick="btnAddTask_Click" />
                <asp:Button ID="btnRefresh" runat="server" Text="🔄 Refresh" 
                    CssClass="btn btn-secondary" OnClick="btnRefresh_Click" />
            </div>
            
            <div class="tasks-grid">
                <h2>📝 Task List</h2>
                <asp:GridView ID="gvTasks" runat="server" AutoGenerateColumns="False" 
                    CssClass="table" GridLines="None" OnRowCommand="gvTasks_RowCommand">
                    <Columns>
                        <asp:BoundField DataField="Id" HeaderText="ID" />
                        <asp:BoundField DataField="Title" HeaderText="Title" />
                        <asp:BoundField DataField="Description" HeaderText="Description" />
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate>
                                <span class='status-badge status-<%# Eval("Status").ToString().ToLower() %>'>
                                    <%# Eval("Status") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="CreatedDate" HeaderText="Created" 
                            DataFormatString="{0:MM/dd/yyyy HH:mm}" />
                        <asp:TemplateField HeaderText="Actions">
                            <ItemTemplate>
                                <asp:Button ID="btnComplete" runat="server" Text="✓ Complete" 
                                    CommandName="CompleteTask" CommandArgument='<%# Eval("Id") %>'
                                    CssClass="btn btn-primary" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div style="text-align: center; padding: 20px; color: #999;">
                            No tasks found. Add your first task above!
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>
            </div>
        </div>
    </form>
</body>
</html>
