//
//  CKDatabaseExtensions.swift
//  Sporadic
//
//  Created by brendan on 12/17/23.
//

import Foundation
import CloudKit

// https://stackoverflow.com/questions/71200053/swift-cloudkit-and-ckquery-how-to-iteratively-retrieve-records-when-queryresult
public extension CKDatabase {
  /// Request `CKRecord`s that correspond to a Swift type.
  ///
  /// - Parameters:
  ///   - recordType: Its name has to be the same in your code, and in CloudKit.
  ///   - predicate: for the `CKQuery`
  func records<Record>(
    type _: Record.Type,
    zoneID: CKRecordZone.ID? = nil,
    predicate: NSPredicate = .init(value: true)
  ) async throws -> [CKRecord] {
    try await withThrowingTaskGroup(of: [CKRecord].self) { group in
      func process(
        _ records: (
          matchResults: [(CKRecord.ID, Result<CKRecord, Error>)],
          queryCursor: CKQueryOperation.Cursor?
        )
      ) async throws {
        group.addTask {
          try records.matchResults.map { try $1.get() }
        }
        
        if let cursor = records.queryCursor {
          try await process(self.records(continuingMatchFrom: cursor))
        }
      }

      try await process(
        records(
          matching: .init(
            recordType: "\(Record.self)",
            predicate: predicate
          ),
          inZoneWith: zoneID
        )
      )
      
      return try await group.reduce(into: [], +=)
    }
  }
}
