import Foundation


class KMeansPoint {
  var x:Double = 0.0
  var y:Double = 0.0
  var label: String?
  
  init(x:Double,y:Double) {
    self.x = x
    self.y = y
  }
  
  func distanceTo(p:KMeansPoint) -> Double {
    return sqrt(pow(self.x - p.x, 2.0) + pow(self.y - p.y, 2.0));
  }
  
}


class KMeansGroup {
  var points = [KMeansPoint]()
  var candidateMean = KMeansPoint(x:0,y:0)
  
  func mean() -> KMeansPoint {
    var avgP = KMeansPoint(x: 0, y: 0);
    if self.points.count > 0 {
      avgP.x = self.points.map({$0.x as Double}).reduce(0, combine: +) / Double(self.points.count)
      avgP.y = self.points.map({$0.y as Double}).reduce(0, combine: +) / Double(self.points.count)
    }
    return avgP
  }
  
  func iterate() {
    self.candidateMean = self.mean()
    self.points = []
  }
  
  func sumSquaredErrors() -> Double {
    var s = self.points.map({ pow($0.distanceTo(self.candidateMean) as Double, 2)}).reduce(0, combine: +)
    return s;
  }
  
  func candidateError() -> Double {
    return self.candidateMean.distanceTo(self.mean())
  }
}


class KMeansCluster {
  var groups = [KMeansGroup]()
  var points = [KMeansPoint]()
  var convergenceCriteria = 0.01
  var maxIterations = 1000
  
  func sumSquaredErrors() -> Double {
    return self.groups.map({$0.sumSquaredErrors()}).reduce(0, combine: +)
  }
  
  func findMeans(count:Int) -> Int {
    var iterations = 0
    if self.points.count == 0 || count == 0 {
      return 0
    }
    if count > self.points.count {
      return 0
    }
    var initialCandidates = [KMeansPoint]()
    
    // to-do: 
    // find maximally distant points
    for i in 0...count-1 {
      var newGroup  = KMeansGroup()
      newGroup.candidateMean = self.points[i]
      self.groups.append(newGroup)
    }
    
    while iterations < maxIterations {
      for p in self.points {
        // which mean is closest?
        let closestMean = self.groups.sorted({$0.candidateMean.distanceTo(p) < $1.candidateMean.distanceTo(p)}).first
        closestMean?.points.append(p)
      }
      let change = self.groups.map({$0.candidateError() as Double}).reduce(0, combine: +)
      if change <= self.convergenceCriteria {
        break;
      }
      else {
        self.groups.map({$0.iterate()})
      }
      ++iterations
    }
    return iterations
  }
}







var clusterspace = KMeansCluster()

for i in 1...1000 {
  let x = Double(arc4random_uniform(1000))
  let y = Double(arc4random_uniform(1000))
  clusterspace.points.append(KMeansPoint(x: x, y: y))
}


for k in 1...100 {
  let iter = clusterspace.findMeans(k)
  let sse = clusterspace.groups.map({$0.sumSquaredErrors()}).reduce(0, combine: +)
  print("k = \(k) // iterations: \(iter)  //  SSE: \(sse) \n")
}










