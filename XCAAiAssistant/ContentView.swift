//
//  ContentView.swift
//  XCAAiAssistant
//
//  Created by Никита Бабанин on 27/11/2023.
//

import SwiftUI
import SiriWaveView

struct ContentView: View {
    @State var viewModel = ViewModel()
    @State var isSymbolAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            Text("XCA AI Voice Assistant")
                .font(.title2)
            
            Spacer()
            SiriWaveView()
                .power(power: viewModel.audioPower)
                .opacity(viewModel.siriWaveFormOpacity)
                .frame(height: 256)
                .overlay { overlayView }
            
            Spacer()
            
            switch viewModel.state {
            case .recordingSpeech:
                cancelRecordingButton
            case .playingSpeech, .processingSpeech:
                cancelButton
            default: EmptyView()
            }
            
            Picker("Select Voice", selection: $viewModel.selectedVoice) {
                ForEach(VoiceType.allCases, id: \.self) {
                    Text($0.rawValue).id($0)
                }
            }
            .pickerStyle(.segmented)
            .disabled(!viewModel.isIdle)
            
            if case let .error(error) = viewModel.state {
                Text(error.localizedDescription)
                    .foregroundStyle(.red)
                    .font(.caption)
                    .lineLimit(2)
            }
        }
        .padding()
    }
    
    @ViewBuilder
    var overlayView: some View {
        switch viewModel.state {
        case .idle, .error:
            startCaptureButton
        case .processingSpeech:
            Image(systemName: "brain")
                .symbolEffect(.bounce.up.byLayer,
                              options: .repeating,
                              value: isSymbolAnimating)
                .font(.system(size: 128))
                .onAppear { isSymbolAnimating = true }
                .onDisappear { isSymbolAnimating = false }
        default: EmptyView()
        }
    }
    
    var startCaptureButton: some View {
        Button {
            viewModel.startCaptureAudio()
        } label: {
            Image(systemName: "mic.circle")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 128))
        }.buttonStyle(.borderless)
    }
    
    var cancelRecordingButton: some View {
        Button(role: .destructive) {
            viewModel.cancelRecording()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 44))
        }.buttonStyle(.borderless)
    }
    
    var cancelButton: some View {
        Button {
            viewModel.cancelProcessingSpeech()
        } label: {
            Image(systemName: "stop.circle.fill")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(.red)
                .font(.system(size: 44))
        }.buttonStyle(.borderless)
    }
}

#Preview("Idle") {
    ContentView()
}

#Preview("Recording speech") {
    let vm = ViewModel()
    vm.state = .recordingSpeech
    return ContentView(viewModel: vm)
}

#Preview("Processing speech") {
    let vm = ViewModel()
    vm.state = .processingSpeech
    vm.audioPower = 0.1
    return ContentView(viewModel: vm)
}

#Preview("Playing speech") {
    let vm = ViewModel()
    vm.state = .playingSpeech
    vm.audioPower = 0.3
    return ContentView(viewModel: vm)
}

#Preview("Error") {
    let vm = ViewModel()
    vm.state = .error("An error has occured")
    return ContentView(viewModel: vm)
}
