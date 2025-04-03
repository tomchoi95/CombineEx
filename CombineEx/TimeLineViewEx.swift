//
//  TimeLineViewEx.swift
//  CombineEx
//
//  Created by 최범수 on 2025-04-03.
//

import SwiftUI

struct TimeLineViewEx: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let timeInterval = timeline.date.timeIntervalSince1970
                let seconds = timeInterval.truncatingRemainder(dividingBy: 60)
                let angle = Angle.degrees(seconds * 6)
                
                context.translateBy(x: size.width / 2, y: size.height / 2)
                context.rotate(by: angle)
                
                let rect = CGRect(x: 0, y: 0, width: 5, height: size.height / 2 - 10)
                context.fill(Path(rect), with: .color(Color.red))
                
            }
            .frame(width: 200, height: 200)
            .background(Circle().stroke(Color.black, lineWidth: 2))
            .task {
                print("TimelineView: \(timeline.date)")
            }
        }
    }
}

#Preview {
    TimeLineViewEx()
}
