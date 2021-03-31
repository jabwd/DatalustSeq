//
//  Client.swift
//  
//
//  Created by Antwan van Houdt on 18/02/2021.
//

import Foundation
import AsyncHTTPClient
import NIOHTTP1

public struct SeqClient {
    private let httpClient: HTTPClient

    public init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    func log(_ message: Message, configuration: SeqConfiguration) {
        let body = HTTPClient.Body.data(message.clefMessage.data(using: .utf8)!)
        let headers = HTTPHeaders([
            ("X-Seq-ApiKey", configuration.key),
            ("Content-Type", "application/vnd.serilog.clef")
        ])
        let url = URL(string: "\(configuration.ingestURL.absoluteString)/api/events/raw?clef")!
        let request = try! HTTPClient.Request(
            url: url,
            method: .POST,
            headers: headers,
            body: body
        )
        httpClient.execute(request: request).whenComplete { result in
            switch result {
            case .failure(let error):
                break
            case .success(let response):
                break
            }
        }
    }
}
