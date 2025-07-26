import SwiftUI

struct CommentView: View {
    let comment: Comment
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Avatar
            Image(comment.authorImage)
                .resizable()
                .frame(width: 24, height: 24)
                .clipShape(Circle())
                .overlay(Circle().stroke(Colors.c1_400, lineWidth: 1))
            
            VStack(alignment: .leading, spacing: 2) {
                // Author name and timestamp
                HStack {
                    Text(comment.author)
                        .font(.custom("VT323-Regular", size: 14))
                        .foregroundColor(Colors.c2_500)
                    
                    Text("•")
                        .font(.custom("VT323-Regular", size: 12))
                        .foregroundColor(Colors.c0_500)
                    
                    Text(formatTimestamp(comment.timestamp))
                        .font(.custom("VT323-Regular", size: 12))
                        .foregroundColor(Colors.c0_500)
                }
                
                // Comment content
                Text(comment.content)
                    .font(.custom("VT323-Regular", size: 14))
                    .foregroundColor(Colors.c0_050)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}

#Preview {
    CommentView(comment: Comment(
        author: "Will Corbett",
        authorImage: "will",
        content: "Great work! 💪",
        timestamp: Date()
    ))
    .padding()
    .background(Color(red: 0.13, green: 0.08, blue: 0.08))
} 