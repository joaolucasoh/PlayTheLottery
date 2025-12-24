// Este arquivo concentra modelos e funções auxiliares para jogos de loteria.
import Foundation

struct GameConfig {
    let name: String
    let totalNumbers: Int
    let maxNumber: Int
}

func randomLottoNumberGenerator(total: Int, maxNumber: Int) -> [String] {
    var numbers = total
    var result: Set<String> = []
    while numbers > 0 {
        let generated = Int.random(in: 1...maxNumber)
        let numberToAdd = (generated == 100) ? "00" : String(format: "%02d", generated)
        let res = result.insert(numberToAdd)
        if res.inserted {
            numbers -= 1
        }
    }
    var sortedResult = result.sorted()
    if let index = sortedResult.firstIndex(of: "00") {
        sortedResult.append(sortedResult.remove(at: index))
    }
    return sortedResult
}
