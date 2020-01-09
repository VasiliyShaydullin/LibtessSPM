# LibtessSPM

A Swift wrapper on top of [Libtess2](https://github.com/memononen/Libtess2)

## Usage

```swift
var tess = LibtessSPM()
tess?.setOption(optin: .constrainedDelanayTriangulation, value: 1)
var vertices: [Vertex] = []
vertices.append(Vertex(x: 0.0, y: 0.0))
vertices.append(Vertex(x: 10.0, y: 0.0))
vertices.append(Vertex(x: 10.0, y: 10.0))
vertices.append(Vertex(x: 0.0, y: 10.0))
vertices.append(Vertex(x: 0.0, y: 0.0))
tessellator?.addContour(size: 2, vertices: vertices, stride: MemoryLayout<Vertex>.stride, count: vertices.count)
let result = tess?.tesselate(windingRule: .odd, elementType: .polygons, polySize: 3, vertexSize: .size2)
guard let (verticesTess, indicesTess) = result else { return }
```

## Installation

LibtessSPM is available as a [Swift Package Manager](https://swift.org/package-manager/):

```ruby
.package(url: "https://github.com/VasiliyShaydullin/LibtessSPM.git", .exact("1.0.5"))
```

## Author

Vasiliy Shaydullin

## License

LibtessSPM is available under the MIT license. See the LICENSE file for more info.
