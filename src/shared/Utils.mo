import Time "mo:base/Time";
import Text "mo:base/Text";
import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Random "mo:base/Random";
import Blob "mo:base/Blob";
import Nat8 "mo:base/Nat8";
import Nat32 "mo:base/Nat32";
import Char "mo:base/Char";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Bool "mo:base/Bool";


    // Text utilities
    func toLowerCase(text: Text) : Text {
        Text.toLowercase(text)
    };

    func toUpperCase(text: Text) : Text {
        Text.toUppercase(text)
    };

    func trim(text: Text) : Text {
        Text.trim(text, #char ' ')
    };

    func contains(text: Text, substring: Text) : Bool {
        Text.contains(text, #text substring)
    };

    func startsWith(text: Text, prefix: Text) : Bool {
        Text.startsWith(text, #text prefix)
    };

    func endsWith(text: Text, suffix: Text) : Bool {
        Text.endsWith(text, #text suffix)
    };

    func split(text: Text, delimiter: Char) : [Text] {
        let parts = Text.split(text, #char delimiter);
        Iter.toArray(parts)
    };

    func join(texts: [Text], separator: Text) : Text {
        Text.join(separator, texts.vals())
    };

    func isValidEmail(email: Text) : Bool {
        let emailPattern = email;
        contains(emailPattern, "@") and contains(emailPattern, ".")
    };

    // Array utilities
    func arrayContains<T>(array: [T], item: T, equal: (T, T) -> Bool) : Bool {
        switch (Array.find<T>(array, func(x) { equal(x, item) })) {
            case null false;
            case (?_) true;
        };
    };

    func arrayUnique<T>(array: [T], equal: (T, T) -> Bool) : [T] {
        let buffer = Buffer.Buffer<T>(0);
        for (item in array.vals()) {
            if (not arrayContains(Buffer.toArray(buffer), item, equal)) {
                buffer.add(item);
            };
        };
        Buffer.toArray(buffer)
    };

    func arrayIntersection<T>(array1: [T], array2: [T], equal: (T, T) -> Bool) : [T] {
        Array.filter<T>(array1, func(item) {
            arrayContains(array2, item, equal)
        })
    };

    // Time utilities
    func currentTime() : Int {
        Time.now()
    };

    func timeToString(timestamp: Int) : Text {
        // Simple timestamp to string conversion
        Int.toText(timestamp)
    };

    func daysBetween(start: Int, end: Int) : Int {
        let diff = end - start;
        let dayInNanos = 24 * 60 * 60 * 1000000000;
        diff / dayInNanos
    };

    func addDays(timestamp: Int, days: Int) : Int {
        let dayInNanos = 24 * 60 * 60 * 1000000000;
        timestamp + (days * dayInNanos)
    };

    func isExpired(timestamp: Int) : Bool {
        timestamp < Time.now()
    };

    // Random utilities
    func generateId(prefix: Text, counter: Nat) : Text {
        prefix # "_" # Nat.toText(counter)
    };

    func generateRandomString(length: Nat, seed: Blob) : Text {
        let chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        let charsArray = Text.toArray(chars);
        let buffer = Buffer.Buffer<Char>(length);
        
        var randomBytes = seed;
        for (i in Iter.range(0, length - 1)) {
            let byteArray = Blob.toArray(randomBytes);
            if (byteArray.size() > 0) {
                let randomIndex = Nat8.toNat(byteArray[0]) % charsArray.size();
                buffer.add(charsArray[randomIndex]);
                // Generate new random bytes for next iteration
                randomBytes := Blob.fromArray([byteArray[0] +% 1]);
            } else {
                buffer.add('a'); // fallback
            };
        };
        
        Text.fromArray(Buffer.toArray(buffer))
    };

    // Validation utilities
    func validateRequired(text: Text, fieldName: Text) : Result.Result<(), Text> {
        if (Text.size(text) == 0) {
            #err(fieldName # " is required")
        } else {
            #ok(())
        }
    };

    func validateLength(text: Text, minLength: Nat, maxLength: Nat, fieldName: Text) : Result.Result<(), Text> {
        let length = Text.size(text);
        if (length < minLength) {
            #err(fieldName # " must be at least " # Nat.toText(minLength) # " characters")
        } else if (length > maxLength) {
            #err(fieldName # " must be no more than " # Nat.toText(maxLength) # " characters")
        } else {
            #ok(())
        }
    };

    func validateEmail(email: Text) : Result.Result<(), Text> {
        if (not isValidEmail(email)) {
            #err("Invalid email format")
        } else {
            #ok(())
        }
    };

    func validatePositiveNumber(number: Nat, fieldName: Text) : Result.Result<(), Text> {
        if (number == 0) {
            #err(fieldName # " must be greater than 0")
        } else {
            #ok(())
        }
    };

    func validateRange(number: Nat, min: Nat, max: Nat, fieldName: Text) : Result.Result<(), Text> {
        if (number < min or number > max) {
            #err(fieldName # " must be between " # Nat.toText(min) # " and " # Nat.toText(max))
        } else {
            #ok(())
        }
    };

    // Principal utilities
    func principalToText(p: Principal) : Text {
        Principal.toText(p)
    };

    func textToPrincipal(t: Text) : ?Principal {
        do ? {
            Principal.fromText(t)
        }
    };

    func isAnonymous(p: Principal) : Bool {
        Principal.isAnonymous(p)
    };

    // Pagination utilities
    func paginate<T>(items: [T], page: Nat, limit: Nat) : {
        data: [T];
        total: Nat;
        page: Nat;
        limit: Nat;
        hasNext: Bool;
    } {
        let total = items.size();
        let start = page * limit;
        let end = Nat.min(start + limit, total);
        
        let paginatedItems = if (start >= total) {
            []
        } else {
            Array.subArray(items, start, Nat.max(0, end - start))
        };

        {
            data = paginatedItems;
            total = total;
            page = page;
            limit = limit;
            hasNext = end < total;
        }
    };

    // Search utilities
    func fuzzyMatch(text: Text, Query: Text) : Bool {
        let textLower = Text.toLowercase(text);
        let queryLower = Text.toLowercase(Query);
        Text.contains(textLower, #text queryLower)
    };

    func calculateSimilarity(text1: Text, text2: Text) : Float {
        // Simple similarity calculation based on common characters
       let chars1 = Text.toArray(Text.toLowercase(text1));
       let chars2 = Text.toArray(Text.toLowercase(text2));
        
        var commonChars = 0;
        for (char1 in chars1.vals()) {
            if (arrayContains(chars2, char1, func(a: Char, b: Char): Bool { a == b })) {
                commonChars += 1;
            };
        };
        
        let maxLength = Nat.max(chars1.size(), chars2.size());
        if (maxLength == 0) {
            1.0
        } else {
            Float.fromInt(commonChars) / Float.fromInt(maxLength)
        }
    };

    // Hash utilities
    func simpleHash(text: Text) : Nat32 {
        Text.hash(text)
    };

    func combineHashes(hash1: Nat32, hash2: Nat32) : Nat32 {
        hash1 +% hash2
    };

    // Error handling utilities
    func mapError<T, E1, E2>(result: Result.Result<T, E1>, mapFn: (E1) -> E2) : Result.Result<T, E2> {
        switch (result) {
            case (#ok(value)) { #ok(value) };
            case (#err(error)) { #err(mapFn(error)) };
        }
    };

    func flatMapError<T, E>(result: Result.Result<T, E>) : Result.Result<T, Text> {
        switch (result) {
            case (#ok(value)) { #ok(value) };
            case (#err(_)) { #err("Operation failed") };
        }
    };

    // Logging utilities (simplified)
    func logInfo(message: Text) {
        // In a real implementation, this would use proper logging
        // For now, we'll use debug print
        Debug.print("[INFO] " # message);
    };

    func logError(message: Text) {
        Debug.print("[ERROR] " # message);
    };

    func logWarning(message: Text) {
        Debug.print("[WARNING] " # message);
    };

    // Data transformation utilities
    func optionToResult<T>(option: ?T, errorMessage: Text) : Result.Result<T, Text> {
        switch (option) {
            case (?value) { #ok(value) };
            case null { #err(errorMessage) };
        }
    };

    func resultToOption<T, E>(result: Result.Result<T, E>) : ?T {
        switch (result) {
            case (#ok(value)) { ?value };
            case (#err(_)) { null };
        }
    };

    // File utilities
   func getFileExtension(filename: Text) : Text {
    let partsIter = Text.split(filename, #char '.');
    let parts = Iter.toArray(partsIter);
    if (parts.size() > 1) {
        parts[parts.size() - 1]
    } else {
        ""
    }
};

    func isValidFileType(filename: Text, allowedTypes: [Text]) : Bool {
        let extension = Text.toLowercase(getFileExtension(filename));
        Array.find<Text>(allowedTypes, func x = Text.equal(x, extension)) != null
    };

    // URL utilities
    func buildIPFSUrl(hash: Text) : Text {
        "ipfs://" # hash
    };

    func extractIPFSHash(url: Text) : ?Text {
    if (Text.startsWith(url, #text "ipfs://")) {
        let hash = Text.trimStart(url, #text "ipfs://");
        if (Text.size(hash) > 0) {
            ?hash
        } else {
            null
        }
    } else {
        null
    }
};

    // Math utilities
    func percentage(part: Nat, whole: Nat) : Float {
        if (whole == 0) {
            0.0
        } else {
            (Float.fromInt(part) / Float.fromInt(whole)) * 100.0
        }
    };

    func average(numbers: [Nat]) : Float {
        if (numbers.size() == 0) {
            0.0
        } else {
            let sum = Array.foldLeft<Nat, Nat>(numbers, 0, func(acc, x) { acc + x });
            Float.fromInt(sum) / Float.fromInt(numbers.size())
        }
    };

    func median(numbers: [Nat]) : Float {
        if (numbers.size() == 0) {
            0.0
        } else {
            let sorted = Array.sort(numbers, Nat.compare);
            let middle = sorted.size() / 2;
            if (sorted.size() % 2 == 0) {
                (Float.fromInt(sorted[middle - 1]) + Float.fromInt(sorted[middle])) / 2.0
            } else {
                Float.fromInt(sorted[middle])
            }
        }
    };
