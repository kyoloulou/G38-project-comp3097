import Foundation
import Combine

class AuthStore: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentEmail: String = ""
    @Published var store: WorkoutStore = WorkoutStore(userEmail: "")

    private let loggedInKey = "auth_logged_in_email"

    init() {
        if let email = UserDefaults.standard.string(forKey: loggedInKey), !email.isEmpty {
            currentEmail = email
            store = WorkoutStore(userEmail: email)
            isLoggedIn = true
        }
    }

    func register(email: String, password: String) -> String? {
        let e = email.trimmingCharacters(in: .whitespaces).lowercased()
        guard isValidEmail(e)     else { return "Enter a valid email address." }
        guard password.count >= 8 else { return "Password must be at least 8 characters." }
        guard KeychainHelper.load(forKey: e) == nil else { return "An account with this email already exists." }

        KeychainHelper.save(password.sha256, forKey: e)
        UserDefaults.standard.set(e, forKey: loggedInKey)
        currentEmail = e
        store = WorkoutStore(userEmail: e)
        isLoggedIn = true
        return nil
    }

    func signIn(email: String, password: String) -> String? {
        let e = email.trimmingCharacters(in: .whitespaces).lowercased()
        guard let stored = KeychainHelper.load(forKey: e) else { return "No account found for this email." }
        guard stored == password.sha256 else { return "Incorrect password." }
        UserDefaults.standard.set(e, forKey: loggedInKey)
        currentEmail = e
        store = WorkoutStore(userEmail: e)
        isLoggedIn = true
        return nil
    }

    func signOut() {
        UserDefaults.standard.removeObject(forKey: loggedInKey)
        currentEmail = ""
        store = WorkoutStore(userEmail: "")
        isLoggedIn = false
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: regex, options: .regularExpression) != nil
    }
}
