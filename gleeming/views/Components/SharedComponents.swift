//
//  SharedComponents.swift
//  gleeming
//
//  Created by ervan on 10/09/25.
//

import SwiftUI

// MARK: - SettingRow Component
struct SettingRow<Content: View>: View {
    let title: String
    let value: String
    let content: Content
    
    init(title: String, value: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.value = value
        self.content = content()
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            content
        }
    }
}
