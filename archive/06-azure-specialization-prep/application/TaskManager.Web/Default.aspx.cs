using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace TaskManager.Web
{
    public partial class Default : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["TaskManagerDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadServerInfo();
                LoadTasks();
                UpdateStatistics();
            }
        }

        private void LoadServerInfo()
        {
            // Display server name to show load balancing
            lblServerName.Text = Environment.MachineName;

            // Test database connection
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    lblDatabaseStatus.Text = "Connected ✓";
                }
            }
            catch (Exception ex)
            {
                lblDatabaseStatus.Text = "Connection Error ✗";
                ShowError($"Database connection failed: {ex.Message}");
            }
        }

        private void LoadTasks()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        SELECT Id, Title, Description, Status, CreatedDate 
                        FROM Tasks 
                        ORDER BY CreatedDate DESC";

                    SqlDataAdapter adapter = new SqlDataAdapter(query, conn);
                    DataTable dt = new DataTable();
                    adapter.Fill(dt);

                    gvTasks.DataSource = dt;
                    gvTasks.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowError($"Error loading tasks: {ex.Message}");
            }
        }

        private void UpdateStatistics()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Total tasks
                    string totalQuery = "SELECT COUNT(*) FROM Tasks";
                    SqlCommand totalCmd = new SqlCommand(totalQuery, conn);
                    int totalTasks = (int)totalCmd.ExecuteScalar();
                    lblTotalTasks.Text = totalTasks.ToString();

                    // Completed tasks
                    string completedQuery = "SELECT COUNT(*) FROM Tasks WHERE Status = 'Completed'";
                    SqlCommand completedCmd = new SqlCommand(completedQuery, conn);
                    int completedTasks = (int)completedCmd.ExecuteScalar();
                    lblCompletedTasks.Text = completedTasks.ToString();

                    // Pending tasks
                    string pendingQuery = "SELECT COUNT(*) FROM Tasks WHERE Status = 'Pending'";
                    SqlCommand pendingCmd = new SqlCommand(pendingQuery, conn);
                    int pendingTasks = (int)pendingCmd.ExecuteScalar();
                    lblPendingTasks.Text = pendingTasks.ToString();
                }
            }
            catch (Exception ex)
            {
                ShowError($"Error updating statistics: {ex.Message}");
            }
        }

        protected void btnAddTask_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTaskTitle.Text))
            {
                ShowError("Please enter a task title.");
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        INSERT INTO Tasks (Title, Description, Status, CreatedDate) 
                        VALUES (@Title, @Description, 'Pending', GETDATE())";

                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@Title", txtTaskTitle.Text.Trim());
                    cmd.Parameters.AddWithValue("@Description", 
                        string.IsNullOrWhiteSpace(txtTaskDescription.Text) ? 
                        (object)DBNull.Value : txtTaskDescription.Text.Trim());

                    cmd.ExecuteNonQuery();

                    ShowMessage($"Task '{txtTaskTitle.Text}' added successfully!");
                    
                    // Clear form
                    txtTaskTitle.Text = string.Empty;
                    txtTaskDescription.Text = string.Empty;

                    // Reload data
                    LoadTasks();
                    UpdateStatistics();
                }
            }
            catch (Exception ex)
            {
                ShowError($"Error adding task: {ex.Message}");
            }
        }

        protected void gvTasks_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "CompleteTask")
            {
                int taskId = Convert.ToInt32(e.CommandArgument);
                CompleteTask(taskId);
            }
        }

        private void CompleteTask(int taskId)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = "UPDATE Tasks SET Status = 'Completed' WHERE Id = @TaskId";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@TaskId", taskId);

                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        ShowMessage("Task marked as completed!");
                        LoadTasks();
                        UpdateStatistics();
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError($"Error completing task: {ex.Message}");
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadTasks();
            UpdateStatistics();
            ShowMessage("Data refreshed successfully!");
        }

        private void ShowMessage(string message)
        {
            lblMessage.Text = message;
            pnlMessage.Visible = true;
            pnlError.Visible = false;
        }

        private void ShowError(string error)
        {
            lblError.Text = error;
            pnlError.Visible = true;
            pnlMessage.Visible = false;
        }
    }
}
