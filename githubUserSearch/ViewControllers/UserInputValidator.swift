//
//  UserInputValidator.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 02.03.2021.
//

import UIKit

enum UserInputError: LocalizedError {
    case stringTooShort(minLength: Int)
    case stringTooLong(maxLength: Int)
    case restrictedCharacters(characters: Set<Character>)
    case hasRestrictedCharacters
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .stringTooShort(let minLength):
            return "Слишком короткая строка - минимум \(minLength.pluralForm(of: PluralizableString(one: "символ", few: "символа", many: "символов")))"
        case .stringTooLong(let maxLength):
            return "Слишком длинная строка - максимум \(maxLength.pluralForm(of: PluralizableString(one: "символ", few: "символа", many: "символов")))"
        case .restrictedCharacters(let characters):
            let output = characters.map({ String($0) }).joined(separator: ", ")
            return "Вы ввели запрещённые символы: \(output)"
        case .hasRestrictedCharacters:
            return "Вы ввели запрещённые символы"
        default:
            return "Произошла неизвестная ошибка"
        }
    }
}

class UserInputValidator {
    private let minLength: Int
    private let maxLength: Int
    private let regex: NSRegularExpression
    private let antiRegex: NSRegularExpression?

    init(allowingLengthsFrom minLength: Int, to maxLength: Int, matching regex: String, negating antiRegex: String? = nil) {
        self.minLength = minLength
        self.maxLength = maxLength
        self.regex = NSRegularExpression(regex)
        if let antiRegex = antiRegex {
            self.antiRegex = NSRegularExpression(antiRegex)
        } else {
            self.antiRegex = nil
        }
    }

    func validateInput(fromTextField textField: UITextField, withCompletion completion: (Result<String, Error>) -> Void) {
        
        guard var term = textField.text else {
            completion(.failure(UserInputError.unknown))
            return
        }
        
        term = term.trimmingCharacters(in: .whitespaces)
        
        guard term.count >= minLength else {
            completion(.failure(UserInputError.stringTooShort(minLength: minLength)))
            return
        }
        
        guard term.count <= maxLength else {
            completion(.failure(UserInputError.stringTooLong(maxLength: maxLength)))
            return
        }
        
        if !regex.matches(term) {
            guard let antiRegex = antiRegex else {
                completion(.failure(UserInputError.hasRestrictedCharacters))
                return
            }
            var restrictedCharacters: Set<Character> = []
            term.forEach { character in
                if antiRegex.matches(String(character)) {
                    restrictedCharacters.insert(character)
                }
            }
            guard !restrictedCharacters.isEmpty else {
                completion(.failure(UserInputError.hasRestrictedCharacters))
                return
            }
            completion(.failure(UserInputError.restrictedCharacters(characters: restrictedCharacters)))
        } else {
            completion(.success(term))
        }
    }
}
