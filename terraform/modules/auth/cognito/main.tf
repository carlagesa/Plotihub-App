# This resource defines the user directory itself.
resource "aws_cognito_user_pool" "main" {
  # The name of the user pool.
  name = "${var.environment}-user-pool"

  # Configure the password policy for our users.
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # How should users sign in? Here, we allow email as a username.
  # The 'alias_attributes' allows users to sign in with either a username or their email.
  username_attributes = ["email"]
  alias_attributes    = ["email", "preferred_username"]

  # Configure how Cognito should handle user account verification (e.g., after sign-up).
  # We will use email for this.
  auto_verified_attributes = ["email"]

  # Tags for resource identification and cost tracking.
  tags = {
    Environment = var.environment
    Project     = "ServerlessAPI"
  }
}

# This resource defines an "app" that can interact with the User Pool.
# Our API Gateway will use this client to authorize requests.
resource "aws_cognito_user_pool_client" "main" {
  name = "${var.environment}-app-client"

  # Link the client to the user pool we created above.
  user_pool_id = aws_cognito_user_pool.main.id

  # We disable the generation of a client secret. This is typical for
  # single-page applications (SPAs) or mobile apps where the secret cannot be stored securely.
  generate_secret = false

  # Defines the OAuth2 flows this client is allowed to use.
  # 'implicit' is common for SPAs.
  allowed_oauth_flows = ["implicit"]
  allowed_oauth_scopes = ["phone", "email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true

  # The URLs our application will redirect to after a successful login.
  # For now, we use a placeholder. This would be our frontend application's URL.
  callback_urls = ["https://localhost:3000/callback"]

  # The URLs our application will redirect to after a logout.
  logout_urls = ["https://localhost:3000/logout"]
}