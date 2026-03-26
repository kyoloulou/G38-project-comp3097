import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthStore

    @State private var email:      String = ""
    @State private var password:   String = ""
    @State private var errorMsg:   String = ""
    @State private var successMsg: String = ""
    @State private var isSignUp:   Bool   = false
    @State private var isLoading:  Bool   = false

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                VStack(spacing: 8) {
                    Image(systemName: "figure.run.circle.fill")
                        .font(.system(size: 72))
                        .foregroundColor(.blue)
                    Text("FitQuest")
                        .font(.largeTitle.bold())
                    Text(isSignUp ? "Create your account" : "Welcome back")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 64)

                VStack(spacing: 14) {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    SecureField("Password", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)

                    if isSignUp {
                        Text("Minimum 8 characters")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 4)
                    }
                }

                if !errorMsg.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.circle.fill")
                        Text(errorMsg)
                    }
                    .font(.footnote)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    .transition(.opacity)
                }

                if !successMsg.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                        Text(successMsg)
                    }
                    .font(.footnote)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 4)
                    .transition(.opacity)
                }

                Button {
                    handleAction()
                } label: {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    } else {
                        Text(isSignUp ? "Sign Up" : "Log In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .font(.headline)
                    }
                }
                .disabled(isLoading)

                Button {
                    withAnimation {
                        isSignUp.toggle()
                        errorMsg   = ""
                        successMsg = ""
                    }
                } label: {
                    Text(isSignUp
                         ? "Already have an account? Log In"
                         : "Don't have an account? Sign Up")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 40)
        }
        .animation(.easeInOut, value: errorMsg)
        .animation(.easeInOut, value: successMsg)
    }

    private func handleAction() {
        errorMsg   = ""
        successMsg = ""
        isLoading  = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if isSignUp {
                if let error = auth.register(email: email, password: password) {
                    withAnimation { errorMsg = error }
                    isLoading = false
                } else {
                    withAnimation { successMsg = "Account created! Signing you in…" }
                    isLoading = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation { auth.isLoggedIn = true }
                    }
                }
            } else {
                if let error = auth.signIn(email: email, password: password) {
                    withAnimation { errorMsg = error }
                    isLoading = false
                } else {
                    withAnimation { successMsg = "Welcome back!" }
                    isLoading = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation { auth.isLoggedIn = true }
                    }
                }
            }
        }
    }
}
