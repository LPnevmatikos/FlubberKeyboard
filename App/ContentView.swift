import SwiftUI

struct ContentView: View {
    @State private var deck = WordDeck()
    @State private var draft = ""
    private let accent = Color(red: 0.44, green: 0.35, blue: 0.60)

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("A keyboard for when you’re percolating, discombobulating, or simply vibing.")
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                        ForEach(0..<9, id: \.self) { index in
                            Button {
                                if let text = deck.tap(at: index) { draft += text }
                            } label: {
                                Text(deck.visibleWords[index])
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, minHeight: 52)
                                    .padding(.horizontal, 3)
                                    .background(index == 2 ? accent.opacity(0.22) : Color(uiColor: .tertiarySystemFill))
                                    .clipShape(RoundedRectangle(cornerRadius: 9))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Insert \(deck.visibleWords[index])")
                        }
                    }
                    TextEditor(text: $draft)
                        .frame(minHeight: 100)
                        .accessibilityLabel("Demo draft")
                    Button("Clear demo", role: .destructive) { draft = "" }
                    Text("This is an in-app demo. Word taps append to this draft. It does not indicate whether the keyboard extension is enabled.")
                        .font(.footnote).foregroundStyle(.secondary)
                } header: { Text("Try the words") }

                Section("Set up the keyboard") {
                    Text("Open Settings → General → Keyboard → Keyboards → Add New Keyboard → Flubber.")
                    Text("Then open an editable text field and use the keyboard picker (touch and hold the globe key) to select Flubber. Use Flubber’s globe to switch among your enabled keyboards.")
                }

                Section("Private and offline") {
                    Text("Words are bundled on your iPhone. Flubber works offline and does not request Full Access. No account or network connection is needed.")
                    Text("Password and phone fields, and apps that disallow third-party keyboards, use the system keyboard.")
                    Text("Each word tap adds the word and a space. Use Space before the first word if your draft needs a separator. Delete removes text once per tap. Send your message from the app you’re writing in.")
                }
            }
            .navigationTitle("Flubber")
            .tint(accent)
        }
    }
}
