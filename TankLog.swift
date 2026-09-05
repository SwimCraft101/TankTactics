//
//  TankLog.swift
//  TankTactics
//
//  Created by Hilton Sherrard on 8/20/26.
//

import Foundation
import SwiftUI

struct LogEntry: Codable {
    let text: String
    let icon: String
}

struct LogView: View {
    let logs: [LogEntry]
    
    var body: some View {
        let logList: String = logs.map { "\(Image(systemName: $0.icon)) " + $0.text }.joined(separator: "\n")
        
        ShapeText(text: logList, shape: TankTacticsHexagon())
    }
}

#Preview {
    LogView(logs: [
        LogEntry(text: "Nathan Brewer shot you, dealing 50􀲗.", icon: "bandage"),
        LogEntry(text: "Nathan Brewer crashed into you, dealing 10􀲗.", icon: "bandage"),
        LogEntry(text: "You crashed into a wall, taking 10􀲗.", icon: "bandage"),
        LogEntry(text: "You were smitten for 10􀲗.", icon: "bandage"),
        LogEntry(text: "The Outer Wall hit you, dealing 50􀲗.", icon: "bandage"),
        LogEntry(text: "Richard Meyer Gausstienlen was killed by Nathan Brewer.", icon: "waveform.path.ecg"),
        LogEntry(text: "Richard Meyer Gausstienlen was killed in a crash with Nathan Brewer.", icon: "waveform.path.ecg"),
        LogEntry(text: "Richard Meyer Gausstienlen got into a fight against a Wall and lost.", icon: "waveform.path.ecg"),
        LogEntry(text: "Richard Meyer Gausstienlen was smitten to death.", icon: "waveform.path.ecg"),
        LogEntry(text: "Richard Meyer Gausstienlen should have escaped the Outer Wall.", icon: "waveform.path.ecg")
    ])
}
