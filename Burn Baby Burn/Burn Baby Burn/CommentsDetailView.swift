import SwiftUI

struct CommentsDetailView: View {
    @Binding var isPresented: Bool
    let comments: [Comment]
    let onCommentPosted: (String) -> Void
    
    @State private var newCommentText: String = ""
    @FocusState private var isInputFocused: Bool
    
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
                
                Button("Post") {
                    postComment()
                }
                .font(.custom("VT323-Regular", size: 16))
                .foregroundColor(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Colors.c0_500 : Colors.c2_500)
                .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            
            // Comment input
            VStack(spacing: 8) {
                TextField(
                    "",
                    text: $newCommentText,
                    prompt: Text("Write a comment...")
                        .font(.custom("VT323-Regular", size: 16))
                        .foregroundColor(Colors.c0_500)
                )
                .font(.custom("VT323-Regular", size: 16))
                .foregroundColor(Colors.c0_050)
                .padding()
                .background(Color(red: 0.20, green: 0.13, blue: 0.13))
                .cornerRadius(8)
                .focused($isInputFocused)
                .submitLabel(.send)
                .onSubmit {
                    postComment()
                }
            }
            .padding()
            .background(Color(red: 0.13, green: 0.08, blue: 0.08))
        }
        .onAppear {
            isInputFocused = true
        }
    }
    
    private func postComment() {
        let trimmed = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        onCommentPosted(trimmed)
        newCommentText = ""
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