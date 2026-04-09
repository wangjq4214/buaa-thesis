#import "constant.typ": font-size, font-type

#let bib(bibliography: none) = {
  assert(bib != none, message: "Bibliography path must be provided")

  set text(size: font-size.five, font: font-type.sun)
  set par(leading: 1em, spacing: 1em, justification-limits: (
    tracking: (min: -0.01em, max: 0.02em),
  ))

  bibliography(style: "gb-7714-2015-numeric", title: none)
}
