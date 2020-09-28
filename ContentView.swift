//
//  ContentView.swift
//  WordScramble
//
//  Created by Ping Yun on 9/28/20.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]() //stores array of words already used
    @State private var rootWord = "" //stores root word to spell other words from
    @State private var newWord = "" //stores created word, can be bound to text field
    @State private var errorTitle = "" //stores title of error
    @State private var errorMessage = "" //stores error message
    @State private var showingError = false //stores whether or not error is showing
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord) //addNewWord is called whenever return is pressed
                    .textFieldStyle(RoundedBorderTextFieldStyle()) //makes text field more visible
                    .autocapitalization(.none) //disables autocapitalization for text field
                    .padding() //so text field doesn't touch edges of screen
                
                //makes one row for every word in usedWords uniquely identified by word itself
                List(usedWords, id: \.self) {
                    Image(systemName: "\($0.count).circle") //words slide into list with length icon to the side
                    Text($0)
                }
            }
            .navigationBarTitle(rootWord) //displays root word as title
            .onAppear(perform: startGame) //calls startGame() when view is shown
            //alert shown when showingError is true
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func addNewWord() {
        //lowercase and trim word to make sure no duplicate words with case differences are added
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        //exit if remaining string is empty
        guard answer.count > 0 else {
            return
        }
        
        //checks if word has not been used before, otherwise error
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        //checks if word can be made from root word, otherwise error
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        //checks if word is a real word, otherwise error 
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }
        usedWords.insert(answer, at: 0) //inserts answer at position 0 in usedWords array
        newWord = "" //resets newWord to empty string
    }
    
    func startGame() {
        //1. Find the URL for start.txt in app bundle
        if let startwordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            //2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startwordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"
                
                // If we are here everything has worked, so we can exit
                return
            }
        }
        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    //accepts string as only parameter, returns true/false depending on if word has been used or not
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    //accepts string as parameter, returns true/false depending on if word can be made from root word
    func isPossible(word: String) -> Bool {
        //creates variable copy of root word
        var tempWord = rootWord
        
        //loops over each letter of input word to see if it exists in copy
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos) //if it exists we remove it from the copy
            } else{
                return false //if not return false
            }
        }
        return true //if we make it to end of input word, return true
    }
    
    //accepts string as parameter, returns true/false depending on if word is a real word
    func isReal(word: String) -> Bool {
        //creates instance of UITextChecker which scans strings for misspelled words
        let checker = UITextChecker()
        //creates NSRange to scan entire length of string
        let range = NSRange(location: 0, length: word.utf16.count)
        //calls rangeOfMisspelledWord() on text checker so it looks for wrong words
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        //returns true if word was OK, false otherwise
        return misspelledRange.location == NSNotFound
    }
    
    //sets title and message based on parameters, flips showingError Boolean to true
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 11")
    }
}
