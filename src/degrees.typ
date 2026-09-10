// The academic degree and the name of the thesis both follow from the type of thesis, and
// for most degrees from the author's gender — exactly as \setthesis, \setmasterdegree and
// \setdoctordegree derive them in the class. Nothing here is typed by the author, so a
// degree cannot be misspelt and cannot disagree with the thesis type.
//
// The names are identical in German and English, which is why they do not live in the
// translation table. A gendered degree is written as a pair, masculine first.

#let bachelor-degree = "Bachelor of Science"

#let master-degrees = (
  "dipl.": (
    thesis-name: "diploma",
    degree: ("Diplom-Ingenieur", "Diplom-Ingenieurin"),
  ),
  "master": (
    thesis-name: "master",
    degree: "Master of Science",
  ),
  "rer.nat.": (
    thesis-name: "master",
    degree: ("Magister der Naturwissenschaften", "Magistra der Naturwissenschaften"),
  ),
  "rer.soc.oec.": (
    thesis-name: "master",
    degree: (
      "Magister der Sozial- und Wirtschaftswissenschaften",
      "Magistra der Sozial- und Wirtschaftswissenschaften",
    ),
  ),
)

#let doctor-degrees = (
  "rer.nat.": ("Doktor der Naturwissenschaften", "Doktorin der Naturwissenschaften"),
  "techn.": ("Doktor der Technischen Wissenschaften", "Doktorin der Technischen Wissenschaften"),
  "rer.soc.oec.": (
    "Doktor der Sozial- und Wirtschaftswissenschaften",
    "Doktorin der Sozial- und Wirtschaftswissenschaften",
  ),
)

#let quoted(values) = values.map(v => "\"" + v + "\"").join(", ")

/// Pick the masculine or feminine form of a degree. A plain string is the same either way.
#let gendered(degree, gender) = {
  if type(degree) != array {
    return degree
  }
  assert(
    gender in ("male", "female"),
    message: "the degree \"" + degree.first() + "\" has a masculine and a feminine form, so "
      + "the author needs a `gender` of \"male\" or \"female\"",
  )
  if gender == "male" { degree.first() } else { degree.at(1) }
}

/// Resolve the thesis type into the wording the title page needs.
///
/// Returns the key of the thesis name in the translation table, the degree awarded, and
/// whether this is a graduate degree — a dissertation is laid out differently from a thesis.
#let resolve-degree(thesis-type, master-degree, doctor-degree, gender, degree) = {
  assert(
    thesis-type in ("bachelor", "master", "doctor"),
    message: "thesis-type must be \"bachelor\", \"master\" or \"doctor\", not \""
      + thesis-type + "\"",
  )

  let resolved = if thesis-type == "bachelor" {
    (thesis-name: "bachelor", degree: bachelor-degree)
  } else if thesis-type == "master" {
    assert(
      master-degree in master-degrees,
      message: "a master's thesis needs a master-degree of " + quoted(master-degrees.keys())
        + ", not \"" + repr(master-degree) + "\"",
    )
    master-degrees.at(master-degree)
  } else {
    assert(
      doctor-degree in doctor-degrees,
      message: "a dissertation needs a doctor-degree of " + quoted(doctor-degrees.keys())
        + ", not \"" + repr(doctor-degree) + "\"",
    )
    (thesis-name: "doctor", degree: doctor-degrees.at(doctor-degree))
  }

  (
    thesis-name: resolved.thesis-name,
    // An explicit degree wins, for the rare award the class does not list.
    degree: if degree == auto { gendered(resolved.degree, gender) } else { degree },
    graduate: thesis-type == "doctor",
  )
}
