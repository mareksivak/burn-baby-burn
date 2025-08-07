import SwiftUI

struct CommentsDetailView: View {
    @Binding var isPresented: Bool
    let comments: [Comment]
    let onCommentPosted: (String) -> Void
    
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var keyboardIsVisible: Bool = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Close") {
                    isPresented = false
                }
                .font(.custom("VT323-Regular", size: 16))
                .foregroundColor(Colors.c0_500)
                
                Spacer()
                
                Text("Comments (\(comments.count))")
                    .font(.custom("VT323-Regular", size: 18))
                    .foregroundColor(Colors.c0_050)
                
                Spacer()
            }
            .padding()
            .background(Color(red: 0.15, green: 0.1, blue: 0.1))
            
            // Comments list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(comments) { comment in
                        CommentView(comment: comment)
                        
                        if comment.id != comments.last?.id {
                            Divider()
                                .background(Colors.c0_500.opacity(0.3))
                                .padding(.horizontal, 12)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .background(Color(red: 0.13, green: 0.08, blue: 0.08))
            
            // Comment input bar (exact same UI from ChatView)
            VStack(spacing: 0) {
                // First row: TextField
                TextField(
                    "",
                    text: $inputText,
                    prompt: Text("Write a comment...")
                        .font(.custom("VT323-Regular", size: 22))
                        .foregroundColor(Colors.c0_500)
                )
                .font(.custom("VT323-Regular", size: 22))
                .foregroundColor(Colors.c0_050)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(red: 0.20, green: 0.13, blue: 0.13))
                .frame(maxWidth: .infinity, minHeight: 44, maxHeight: 44)
                .cornerRadius(0)
                .focused($isInputFocused)
                .submitLabel(.send)
                .onSubmit {
                    postComment()
                }
                // Add space between text input and buttons
                Spacer().frame(height: 8)
                // Second row: Actions and send arrow
                HStack(spacing: 24) {
                    Button(action: {}) {
                        Image("workout")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .frame(width: 38, height: 28)
                    }
                    Button(action: {}) {
                        Image("add")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                            .frame(width: 38, height: 28)
                    }
                    Spacer()
                    if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Button(action: {
                            postComment()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(red: 0.20, green: 0.13, blue: 0.13))
                                .frame(width: 38, height: 28)
                                .background(Colors.c2_500)
                        }
                    }
                }
                .foregroundColor(Colors.c0_050)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, minHeight: 28, maxHeight: 28)
                .background(Color(red: 0.20, green: 0.13, blue: 0.13))
            }
            .background(Color(red: 0.20, green: 0.13, blue: 0.13))
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: keyboardIsVisible ? 12 : 0)
            }
        }
        .onAppear {
            isInputFocused = true
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                keyboardIsVisible = true
                if let keyboardFrame = (UIApplication.shared.windows.first?.rootViewController?.view.window?.inputViewController?.view.frame) {
                    keyboardHeight = keyboardFrame.height
                } else {
                    keyboardHeight = 300 // fallback
                }
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardIsVisible = false
                keyboardHeight = 0
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    private func postComment() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        onCommentPosted(trimmed)
        inputText = ""
    }
}

#Preview {
    CommentsDetailView(
        isPresented: .constant(true),
        comments: [
            Comment(author: "Will", authorImage: "will", content: "Great work! 💪", timestamp: Date()),
            Comment(author: "Nic", authorImage: "nic", content: "Keep it up! 🔥", timestamp: Date()),
            Comment(author: "Marek", authorImage: "marek", content: "Amazing progress! 👏", timestamp: Date())
        ],
        onCommentPosted: { comment in
            print("Posted comment: \(comment)")
        }
    )
} 