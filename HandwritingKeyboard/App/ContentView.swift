import SwiftUI
import PencilKit

/// Main app screen: setup steps for the keyboard, plus a practice pad.
/// The practice pad also works on a Mac, where keyboards aren't supported.
struct ContentView: View {
    @State private var drawing = PKDrawing()
    @State private var message = "Write below, then tap Copy"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    setupSteps
                    practicePad
                }
                .padding()
                .frame(maxWidth: 800)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("Handwriting Keyboard")
        }
    }

    private var setupSteps: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Turn on the keyboard").font(.title2.bold())
            Label("Open **Settings › General › Keyboard › Keyboards**", systemImage: "1.circle")
            Label("Tap **Add New Keyboard…** and pick **Handwriting**", systemImage: "2.circle")
            Label("Tap **Handwriting** and switch on **Allow Full Access** (needed to copy your writing)", systemImage: "3.circle")
            Label("In any app, tap the 🌐 globe key to switch to it", systemImage: "4.circle")
            Label("Write, tap **Copy**, then long-press the text box › **Paste**", systemImage: "5.circle")
        }
    }

    private var practicePad: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Practice pad").font(.title2.bold())

            DrawingPad(drawing: $drawing)
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray.opacity(0.4)))

            HStack {
                Button(role: .destructive) {
                    drawing = PKDrawing()
                    message = "Write below, then tap Copy"
                } label: {
                    Label("Clear", systemImage: "trash")
                }

                Spacer()

                Button {
                    if HandwritingExporter.copyToClipboard(drawing) {
                        message = "Copied! Paste it anywhere."
                    } else {
                        message = "Write something first ✍️"
                    }
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .buttonStyle(.borderedProminent)
            }

            Text(message).foregroundStyle(.secondary)
        }
    }
}

/// SwiftUI wrapper for PencilKit's canvas.
struct DrawingPad: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .white
        canvas.overrideUserInterfaceStyle = .light
        canvas.tool = PKInkingTool(.pen, color: .black, width: 4)
        canvas.delegate = context.coordinator
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        // Only push changes back to the canvas when the pad was cleared.
        if drawing.strokes.isEmpty && !canvas.drawing.strokes.isEmpty {
            canvas.drawing = drawing
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        private let parent: DrawingPad
        init(_ parent: DrawingPad) { self.parent = parent }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}
