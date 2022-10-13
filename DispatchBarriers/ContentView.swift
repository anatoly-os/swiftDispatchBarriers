//
//  ContentView.swift
//  DispatchBarriers
//
//  Created by anatoly on 13.10.2022.
//

import SwiftUI
import Combine

let concurrentGlobalQueue = DispatchQueue.global(qos: .utility)
let serialMain = DispatchQueue.main
let concurrentCustomBackgroundQoS = DispatchQueue(label: "customTest",
                                     qos: .background,
                                     attributes: .concurrent)
let concurrentCustomUserInitiatedQoS = DispatchQueue(label: "customTarget",
                                           qos: .userInitiated,
                                           attributes: .concurrent)

extension Color {
    static func random() -> Color {
        Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
    }
}

/*
     This view model creates array of 10 white colors
     And change them to random ones in the `init()` asynchronously (faking the assumption that setting a color is a heavy operation)
     Also, public function `changeRandomColor()` allows changing any array's item color randomly
     
     The aim of this class is to show how:
     1. Run heavy operations asynchronously using a cocurrent custom queue
     2. Use DispatchBarrier to prevent changing the array BEFORE all colors are set
     3. How to keep UI interactive while performing heavy operations
 */
class ArrayViewModel: ObservableObject {
    @Published private(set) var array = Array(repeating: Color.white, count: 10)

    private var bag = Set<AnyCancellable>()
    init() {
        // If we remove `(flags: .barrier)` here
        // The `changeRandomColor()` (if invoked from UI) will be able to change the array BEFORE we set all the colors
        concurrentCustomUserInitiatedQoS.async(flags: .barrier) { [weak self] in
//        concurrentCustomUserInitiatedQoS.async { [weak self] in
            guard let self = self else { return }
            for idx in self.array.indices {
                self.heavyOperation()
                serialMain.async {
                    self.array[idx] = Color.random()
                }
                
            }
        }
    }
    
    func changeRandomColor() {
        concurrentCustomUserInitiatedQoS.async {
            // Uncomment to make setting user initiated random color a heavy operation
            // It indicates how we can keep UI responsive while performing heavy operations in a different queue

//            heavyOperation()
            serialMain.async {
                self.array[Int.random(in: 0..<self.array.count)] = Color.random()
            }
        }
    }
    
    private func heavyOperation() {
        for _ in 0...10000000 { let j = 0 }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ArrayViewModel()
    var body: some View {
        ZStack {
            Color.black

            VStack {
                HStack {
                    ForEach(viewModel.array, id: \.hashValue) { color in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(color)
                    }
                }
                .frame(height: 52)
                
                Button(action: { viewModel.changeRandomColor() }) {
                    Text("Change random color")
                        .foregroundColor(.white)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.green)
                        )
                        .frame(height: 52)
                        .padding()
                }
            }
            .padding()
        }
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
