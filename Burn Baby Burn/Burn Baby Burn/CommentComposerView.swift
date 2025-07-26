import SwiftUI

struct CommentComposerView: View {
    @Binding var isPresented: Bool
    let onCommentPosted: (String) -> Void
    
    @State private var commentText: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var showAttachmentOptions: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .font(.custom("VT323-Regular", size: 16))
                .foregroundColor(Colors.c0_500)
                
                Spacer()
                
                Text("Add Comment")
                    .font(.custom("VT323-Regular", size: 18))
                    .foregroundColor(Colors.c0_050)
                
                Spacer()
                
                Button("Post") {
                    postComment()
                }
                .font(.custom("VT323-Regular", size: 16))
                .foregroundColor(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Colors.c0_500 : Colors.c2_500)
                .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color(red: 0.15, green: 0.1, blue: 0.1))
            
            // Comment input
            VStack(spacing: 12) {
                TextField(
                    "",
                    text: $commentText,
                    prompt: Text("Write a comment...")
                        .font(.custom("VT323-Regular", size: 18))
                        .foregroundColor(Colors.c0_500)
                )
                .font(.custom("VT323-Regular", size: 18))
                .foregroundColor(Colors.c0_050)
                .padding()
                .background(Color(red: 0.20, green: 0.13, blue: 0.13))
                .cornerRadius(8)
                .focused($isInputFocused)
                .submitLabel(.send)
                .onSubmit {
                    postComment()
                }
                
                // Attachment options
                HStack(spacing: 16) {
                    Button(action: {
                        showAttachmentOptions.toggle()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "paperclip")
                                .font(.system(size: 16))
                            Text("Attach")
                                .font(.custom("VT323-Regular", size: 14))
                        }
                        .foregroundColor(Colors.c0_500)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.20, green: 0.13, blue: 0.13))
                        .cornerRadius(6)
                    }
                    
                    Button(action: {
                        // Add workout
                    }) {
                        HStack(spacing: 6) {
                            Image("workout")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 16, height: 16)
                            Text("Workout")
                                .font(.custom("VT323-Regular", size: 14))
                        }
                        .foregroundColor(Colors.c0_500)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.20, green: 0.13, blue: 0.13))
                        .cornerRadius(6)
                    }
                    
                    Button(action: {
                        // Add emoji
                    }) {
                        HStack(spacing: 6) {
                            Text("😀")
                                .font(.system(size: 16))
                            Text("Emoji")
                                .font(.custom("VT323-Regular", size: 14))
                        }
                        .foregroundColor(Colors.c0_500)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.20, green: 0.13, blue: 0.13))
                        .cornerRadius(6)
                    }
                    
                    Spacer()
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
        let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        onCommentPosted(trimmed)
        commentText = ""
        isPresented = false
    }
}

#Preview {
    CommentComposerView(
        isPresented: .constant(true),
        onCommentPosted: { comment in
            print("Posted comment: \(comment)")
        }
    )
    .background(Color(red: 0.13, green: 0.08, blue: 0.08))
} 