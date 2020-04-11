import XCTest
@testable import Git

final class CommitTests: Tests {
    func testCommit0() {
        let file = url.appendingPathComponent(".git/objects/0c/bd117f7fe2ec884168863af047e8c89e71aaf1")
        try! FileManager.default.createDirectory(atPath: file.deletingLastPathComponent().path, withIntermediateDirectories: true)
        try! Data(base64Encoded: commit0)!.write(to: file)
        let commit = Commit(file)
        XCTAssertEqual("99ff9f93b7f0f7d300dc3c42d16cdfcdf5c2a82f", commit.tree.keys.first)
        XCTAssertEqual("vauxhall", commit.author.name)
        XCTAssertEqual("zero.griffin@gmail.com", commit.author.email)
        XCTAssertEqual("+0200", commit.author.timezone)
        XCTAssertEqual(1554638195, commit.author.date)
        XCTAssertEqual(commit.author, commit.committer)
        XCTAssertEqual("This is my first commit.\n", commit.message)
        XCTAssertTrue(commit.parent.isEmpty)
    }
    
    func testCommit1() {
        let file = url.appendingPathComponent(".git/objects/72/0f2f1fbe2010e9c4e9ab02e9bd83ad6842d7f0")
        try! FileManager.default.createDirectory(atPath: file.deletingLastPathComponent().path, withIntermediateDirectories: true)
        try! Data(base64Encoded: commit1)!.write(to: file)
        let commit = Commit(file)
        XCTAssertEqual("0cbd117f7fe2ec884168863af047e8c89e71aaf1", commit.parent.keys.first)
        XCTAssertEqual("My second commit.\n", commit.message)
    }
    
    func testCommit2() {
        let file = url.appendingPathComponent(".git/objects/79/be52211d61ef2e59134ae6e8aaa0fe121de71f")
        try! FileManager.default.createDirectory(atPath: file.deletingLastPathComponent().path, withIntermediateDirectories: true)
        try! Data(base64Encoded: commit2)!.write(to: file)
        let commit = Commit(file)
        XCTAssertTrue(commit.parent.keys.contains("890be9af6d5a18a1eb999f0ad44c15a83f227af4"))
        XCTAssertTrue(commit.parent.keys.contains("d27de8c22fb0cfdc7d12f8eaf30bcc5343e7f70a"))
    }
    
    func testCommit3() {
        let file = url.appendingPathComponent(".git/objects/d2/7de8c22fb0cfdc7d12f8eaf30bcc5343e7f70a")
        try! FileManager.default.createDirectory(atPath: file.deletingLastPathComponent().path, withIntermediateDirectories: true)
        try! Data(base64Encoded: commit3)!.write(to: file)
        let commit = Commit(file)
    }
    
    func testCommit4() {
        let file = url.appendingPathComponent(".git/objects/15/788bb7a6220d3386ac0bbf52709e93bc3415ac")
    }
}

private let commit0 = """
eAGdjUEKwyAQRbv2FLMvyKgxiRBKD9ELWHWiECsYU9qevkJvUHirD+8/V3JODYQRp1ZDAGOIDBl1nwhp8grRO+UG6cXoPHW0k3aWxOzRYqnwtMcr2m2D5RNq4WtNROlxXbNNG3clX0BoPYxqFkbDGSUi62tPtvCXzG4x7dDJb6BU9wa/O86+k9VAIA==
"""

private let commit1 = """
eAGdjkFqxDAMAHv2K3QvBMmxYwVK2Q/0EYos7waSuLjepe3rm9If9Doww2jd97WDH/1Tb2bgI3r0y5yYVclynlLMspgiMiEGSnNIsbB7l2ZHB9QlE6WSinlT5kAT8zRKwZCMlWdLJFLIyb3faoOH3D9vsm3w8m2tDte2lrIel+su6zZo3V+BYgzTb2aE5/MF3UnPxW7/kt3bF3yY1iPDX2dwP6+ASeg=
"""

private let commit2 = """
eAGdj01uwyAQhbv2KdhlUSmGAQxUVdUL9BADzNiWjIkIrqqevs4iF+j26f18L9VS1i40qJfeiARaCdaRclqRNnGKpHP0Riprmf2UdLQIE8Fww0Z7Fz7ISAF5yhaVR0UxhMASszFJWfSaARyyefozuEw+AXCUiXNyWQF7QtYypmS10eTYSRzw6Ett4huPnwW3Tbz/UqvXua3M6/45F1y3a6rlQ5xkzoEP4MSrBCmHUz0vdfpXePiiNpOIDfe0iEvB+1l0EZXF0vvt/jaO89qXIz62xyfcWB6h4Q+fomgb
"""

private let commit3 = """
eAF1Uctum0AA7Jmv2LvVZJfXgpRUAT8wSSCGYIxzW2B5FYxZFjB8fd322s5lpJFGmkfSNk3Jgarr3zijFOgI45hCiONYVGKUIZEmiZSlSKYx0lGSQpyqeiYLV8LohQMtTSCJM0hgDFN8J6KpGkwJUXWC0wzLJMkSqisCGXjRMjCS4VaQugZPC2XtQ87KLCsvL3lDyvohaZsfACkKxqKmIxmsoAihcFfvETllwCr5fojB06Vl9FrPL3nJiyH+jy2/5n2Zg++/YW4t2wUH6wA+bcs1gqO//aMLQABTbyamYZhrw/BM7zURPfVz7ZtvuKjkj1Fi9mQY6d62DUvDpTkRUXwLKZKbL5/MGnUbASy2ycn7x2avoG2QXJtq1w4HR9G/rqhiIZ+Hjkj+uhLtqmcVDEM3s7eBHgXp43u2v4yOAFpai3Wg6md+Oo6Durk02C1m4ox5V2TBzHfySRqiVNmZiATTPIrJ0e2UeZW5S1ed67MAft425RxG4jbLFXmeN/0HsuKTL8Kykhq99rHF5j4S208kKSfCI1Wc4NJ4+7avWVwdgnsL45UUlNVNHFkQG+rc+qRKr4/tKhiq7LFklROezGk4z9LJ1tXjyqmU9bDb594YdlJ736GPV5MX+bDv9BzdlPGRrbEG7X5wl0oraomGlXrwnKUO0u5onqfX23pxHC860LOnLNqzAJ6tzbET/n62dTf/fkxYM0o4BeTS8nvgB37jvwCkx97a
"""

private let commit4 = """
eAGFUttum0AQ7TNS/2GlvrR1Y+4LjpIqQAl2HINjcOzwtssuFxvMZcFgf32dpOpTlc7LORrNOZrRmagsiqwF+kT81DaUAkWGMBY0ASmSTFRBhJjqWiQIEsYxFiFEijjBWNa5CjX00AIliqEcIzESY1m/oIYwghhJUUwiCKlEFEWXJUngUNemZQOMnA4mPRxO4OYvvesYbdj4UDa0yk/jJGvTDo+jsvgJRFWHqqioUAIjQRIE7tK97NvSBjhZO+0wuPkju/tQllQJyxJw9Vqm7cxcsHSWwJ85rhGsV/ZbnwMc6JkZmYZhWobxZD490L1dW9bKnGvpTvGOcjPrDYNMZzNjujpLPGKP9X0Yh/vR1joc49Oq4MDm6PObKZn08LHUkgfFchOv0HbRGe7sbD0v+6qcLfpQXG9V4zgEE17cbNO1T3q1Ck+6bnEgzk+Fux3qZxaXlK5JOn1YN0xhLe/mtePvzvsXkix5ZZJ5Xq+bRdbISrrt0kyVp+6jN1yuqMKq0qr2YXXEHqlXe3NieA0Uu1Asa3mAbnW2Cil3TDHQUzTbORt2L2xe9hLb6c9FZnPg4Fq1O/XtMzkFI3wvDGyhLxyP5mVub4OFyIfBwDMBDdp2Lzm6Eo9a7Smokb30SJUokAOMhEPBd5lw8iutORojTOiGYbO3XqQI8scmDHIRR0udebUfTBdhW4TqPMc+fHbvdfuWA7fzVZJy75nZ7q9/J8YZhAC/z+IWLFG0RwkFC3S4QANYV1Vl04KvUV4yCr4omvKN45ar6wud6ODHK6jgM/eZ+w7+6/LxEO6ynIAopdH+1c8qr97fnZIrfLoGR9QNKcpzcHOmTTlOmiyOs8NdUqAsf/vz35nVGrs=
"""
