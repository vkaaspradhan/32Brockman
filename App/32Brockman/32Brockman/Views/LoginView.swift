import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthService
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                VStack(spacing: 22) {
                    VStack(spacing: 6) {
                        Image(systemName: "sparkles.rectangle.stack")
                            .font(.system(size: 52))
                            .foregroundStyle(AppTheme.accent)
                        Text("32Brockman")
                            .font(.largeTitle.bold())
                        Text("Plan. Post. Chat. Stay clean.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 8)

                    VStack(spacing: 14) {
                        TextField("Username", text: $username)
                            .textInputAutocapitalization(.never)
                            .textContentType(.username)
                            .padding(14)
                            .background(.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .padding(14)
                            .background(.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }

                    Button {
                        attemptLogin()
                    } label: {
                        Text("Sign In")
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .foregroundStyle(.white)
                            .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .disabled(username.isEmpty || password.isEmpty)

                    VStack(spacing: 4) {
                        Text("Demo accounts").font(.footnote).foregroundStyle(.secondary)
                        Text("admin / admin123   •   user / user123")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(24)
            }
            .alert("Login failed", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func attemptLogin() {
        if auth.login(username: username, password: password) {
            // success handled by RootView switch
        } else {
            errorMessage = "Incorrect username or password, or account disabled."
            showError = true
        }
    }
}
