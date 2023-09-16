//
//  ContentView.swift
//  Walltagger
//
//  Created by Matteo Comisso on 16/09/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.displayScale) var displayScale

    let currentVersion = UIDevice.current.systemVersion
    let currentSystem = UIDevice.current.systemName

    @State var colorTop: Color = Color(uiColor: .systemBackground)
    @State var colorBottom: Color = Color(uiColor: .systemBackground)
    @State var textColor: Color = Color(uiColor: .label)

    @State var showSettings: Bool = false

    @State var renderedImage: Image = Image(systemName: "photo")

    var background: some View {
        ZStack {
            LinearGradient(colors: [colorTop, colorBottom], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack {
                Spacer()
                Text(currentSystem + " " + currentVersion)
                    .font(.system(size: 60, design: .rounded))
                    .bold()
                    .foregroundStyle(textColor)
                    .padding(.bottom)
            }
        }
    }

    var body: some View {
        NavigationView {
            background
                .toolbar(content: {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showSettings = true
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                        .labelStyle(.iconOnly)
                        .padding()
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        ShareLink("Export", item: renderedImage, preview: SharePreview(Text("Background image"), image: renderedImage))
                            .padding()
                    }
                })
                .sheet(isPresented: $showSettings) {
                    VStack {
                        ColorPicker(selection: $colorTop, supportsOpacity: false) {
                            Text("Top color")
                        }

                        ColorPicker(selection: $colorBottom, supportsOpacity: false) {
                            Text("Bottom color")
                        }
                    }
                    .padding()
                    .presentationDetents([.fraction(0.2)])
                    .presentationDragIndicator(.visible)
                }
        }
        .onAppear { render() }
        .onChange(of: self.colorTop) { _ in
            render()
        }
        .onChange(of: self.colorBottom) { _ in
            render()
        }
    }

    @MainActor func render() {
        let screenSize = UIScreen.main.bounds.size
        let renderer = ImageRenderer(content: background)
        
        renderer.isOpaque = true
        renderer.proposedSize = .init(width: screenSize.width, height: screenSize.height)
        renderer.scale = displayScale

        if let uiImage = renderer.uiImage {
            renderedImage = Image(uiImage: uiImage)
        }
    }
}

#Preview {
    ContentView()
}
