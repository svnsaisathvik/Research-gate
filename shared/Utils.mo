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

module Utils {

    // Text utilities
    public func toLowerCase(text: Text) : Text {
        Text.map(text, Prim.charToLower)
    };

    public func toUpperCase(text: Text) : Text {
        Text.map(text, Prim.charToUpper)
    };

    public func trim(text: Text) : Text {
        Text.trim(text, #char ' ')
    };

    public func contains(text: Text, substring: Text) : Bool {
        Text.contains(text, #text substring)
    };

    public func startsWith(text: Text, prefix: Text) : Bool {
        Text.startsWith(text, #text prefix)
    };

    public func endsWith(text: Text, suffix: Text) : Bool {
        Text.endsWith(text, #text suffix)
    };

    public func split(text: Text, delimiter: Char) : [Text] {
        let parts = Text.split(text, #char delimiter);
        Iter.toArray(parts)
    };

    public func join(texts: [Text], separator: Text) : Text {
        Text.join(separator, texts.vals())
    };

    public func isValidEmail(email: Text) : Bool {
        let emailPattern = email;
        contains(emailPattern, "@") and contains(emailPattern, ".")
    };

    // Array utilities
    public func arrayContains<T>(array: [T], item: T, equal: (T, T) -> Bool) : Bool {
        switch (Array.find<T>(array, func(x) { equal(x, item) })) {
            case null false;
            case (?_) true;
        };
    };

    public func arrayUnique<T>(array: [T], equal: (T, T) -> Bool) : [T] {
        let buffer = Buffer.Buffer<T>(0);
        for (item in array.vals()) {
            if (not arrayContains(Buffer.toArray(buffer), item, equal)) {
                buffer.add(item);
            };
        };
        Buffer.toArray(buffer)
    };

    public func arrayIntersection<T>(array1: [T], array2: [T], equal: (T, T) -> Bool) : [T] {
        Array.filter<T>(array1, func(item) {
            arrayContains(array2, item, equal)
        })
    };

    // Time utilities
    public func currentTime() : Int {
        Time.now()
    };

    public func timeToString(timestamp: Int) : Text {
        // Simple timestamp to string conversion
        Int.toText(timestamp)
    };

    public func daysBetween(start: Int, end: Int) : Int {
        let diff = end - start;
        let dayInNanos = 24 * 60 * 60 * 1000000000;
        diff / dayInNanos
    };

    public func addDays(timestamp: Int, days: Int) : Int {
        let dayInNanos = 24 * 60 * 60 * 1000000000;
        timestamp + (days * dayInNanos)
    };

    public func isExpired(timestamp: Int) : Bool {
        timestamp < Time.now()
    };

    // Random utilities
    public func generateId(prefix: Text, counter: Nat) : Text {
        prefix # "_" # Nat.toText(counter)
    };

    public func generateRandomString(length: Nat, seed: Blob) : Text {
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
    public func validateRequired(text: Text, fieldName: Text) : Result.Result<(), Text> {
        if (Text.size(text) == 0) {
            #err(fieldName # " is required")
        } else {
            #ok(())
        }
    };

    public func validateLength(text: Text, minLength: Nat, maxLength: Nat, fieldName: Text) : Result.Result<(), Text> {
        let length = Text.size(text);
        if (length < minLength) {
            #err(fieldName # " must be at least " # Nat.toText(minLength) # " characters")
        } else if (length > maxLength) {
            #err(fieldName # " must be no more than " # Nat.toText(maxLength) # " characters")
        } else {
            #ok(())
        }
    };

    public func validateEmail(email: Text) : Result.Result<(), Text> {
        if (not isValidEmail(email)) {
            #err("Invalid email format")
        } else {
            #ok(())
        }
    };

    public func validatePositiveNumber(number: Nat, fieldName: Text) : Result.Result<(), Text> {
        if (number == 0) {
            #err(fieldName # " must be greater than 0")
        } else {
            #ok(())
        }
    };

    public func validateRange(number: Nat, min: Nat, max: Nat, fieldName: Text) : Result.Result<(), Text> {
        if (number < min or number > max) {
            #err(fieldName # " must be between " # Nat.toText(min) # " and " # Nat.toText(max))
        } else {
            #ok(())
        }
    };

    // Principal utilities
    public func principalToText(p: Principal) : Text {
        Principal.toText(p)
    };

    public func textToPrincipal(t: Text) : ?Principal {
        try {
            ?Principal.fromText(t)
        } catch (e) {
            null
        }
    };

    public func isAnonymous(p: Principal) : Bool {
        Principal.isAnonymous(p)
    };

    // Pagination utilities
    public func paginate<T>(items: [T], page: Nat, limit: Nat) : {
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
            Array.subArray(items, start, end - start)
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
    public func fuzzyMatch(text: Text, query: Text) : Bool {
        let textLower = toLowerCase(text);
        let queryLower = toLowerCase(query);
        contains(textLower, queryLower)
    };

    public func calculateSimilarity(text1: Text, text2: Text) : Float {
        // Simple similarity calculation based on common characters
        let chars1 = Text.toArray(toLowerCase(text1));
        let chars2 = Text.toArray(toLowerCase(text2));
        
        var commonChars = 0;
        for (char1 in chars1.vals()) {
            if (arrayContains(chars2, char1, func(a, b) { a == b })) {
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
    public func simpleHash(text: Text) : Nat32 {
        Text.hash(text)
    };

    public func combineHashes(hash1: Nat32, hash2: Nat32) : Nat32 {
        hash1 +% hash2
    };

    // Error handling utilities
    public func mapError<T, E1, E2>(result: Result.Result<T, E1>, mapFn: (E1) -> E2) : Result.Result<T, E2> {
        switch (result) {
            case (#ok(value)) { #ok(value) };
            case (#err(error)) { #err(mapFn(error)) };
        }
    };

    public func flatMapError<T, E>(result: Result.Result<T, E>) : Result.Result<T, Text> {
        switch (result) {
            case (#ok(value)) { #ok(value) };
            case (#err(_)) { #err("Operation failed") };
        }
    };

    // Logging utilities (simplified)
    public func logInfo(message: Text) {
        // In a real implementation, this would use proper logging
        // For now, we'll use debug print
        Debug.print("[INFO] " # message);
    };

    public func logError(message: Text) {
        Debug.print("[ERROR] " # message);
    };

    public func logWarning(message: Text) {
        Debug.print("[WARNING] " # message);
    };

    // Data transformation utilities
    public func optionToResult<T>(option: ?T, errorMessage: Text) : Result.Result<T, Text> {
        switch (option) {
            case (?value) { #ok(value) };
            case null { #err(errorMessage) };
        }
    };

    public func resultToOption<T, E>(result: Result.Result<T, E>) : ?T {
        switch (result) {
            case (#ok(value)) { ?value };
            case (#err(_)) { null };
        }
    };

    // File utilities
    public func getFileExtension(filename: Text) : Text {
        let parts = split(filename, '.');
        if (parts.size() > 1) {
            parts[parts.size() - 1]
        } else {
            ""
        }
    };

    public func isValidFileType(filename: Text, allowedTypes: [Text]) : Bool {
        let extension = toLowerCase(getFileExtension(filename));
        arrayContains(allowedTypes, extension, Text.equal)
    };

    // URL utilities
    public func buildIPFSUrl(hash: Text) : Text {
        "ipfs://" # hash
    };

    public func extractIPFSHash(url: Text) : ?Text {
        if (startsWith(url, "ipfs://")) {
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
    public func percentage(part: Nat, whole: Nat) : Float {
        if (whole == 0) {
            0.0
        } else {
            (Float.fromInt(part) / Float.fromInt(whole)) * 100.0
        }
    };

    public func average(numbers: [Nat]) : Float {
        if (numbers.size() == 0) {
            0.0
        } else {
            let sum = Array.foldLeft<Nat, Nat>(numbers, 0, func(acc, x) { acc + x });
            Float.fromInt(sum) / Float.fromInt(numbers.size())
        }
    };

    public func median(numbers: [Nat]) : Float {
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
}