import Combine
import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true
/**
 Sequence - 시퀀스 요소들을 순차적으로 발행
 Map - 각 요소를 변환
 Filter - 조건에 맞는 요소만 통과시킴
 Collect - 모든 요소를 배열로 모음
 Reduce - 값을 누적하여 단일 결과 생성
 CompactMap - nil이 아닌 값만 통과시킴
 RemoveDuplicates - 중복된 요소 제거
 First - 첫 번째 요소만 발행
 Last - 마지막 요소만 발행
 Delay - 지정된 시간 후에 요소 발행
 Throttle - 일정 시간 간격으로 최신 값 발행
 Debounce - 일정 시간 안정화 후 발행
 CombineLatest - 여러 Publisher의 최신 값을 결합
 Zip - 여러 Publisher의 값을 쌍으로 결합
 Merge - 여러 Publisher 스트림을 하나로 병합
 FlatMap - 중첩된 Publisher를 평탄화
 SwitchToLatest - 최신 Publisher로 전환
 Retry - 실패 시 지정된 횟수만큼 재시도
 Catch - 오류 발생 시 대체 Publisher 제공
 Share - 하나의 Publisher를 여러 구독자에게 공유
 */

//let map = MapOperator()
//let filter = FilterOperator()
let collect = CollectOperator()
