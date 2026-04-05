//
//  SignalType.swift
//  Cellumina
//
//  Created by Ansh Srivastava on 10/02/26.
//


import Foundation

enum SignalType: String, CaseIterable, Identifiable {
    case paracrine = "Paracrine"
    case autocrine = "Autocrine"
    case endocrine = "Endocrine"

    var id: String {
        rawValue
    }
}
