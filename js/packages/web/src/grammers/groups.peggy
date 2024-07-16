{
  function validateGroups(groups) {
    const starGroups = groups.filter((g) => g.pattern === null);
    if (starGroups.length > 1) {
      throw new Error("The '*' pattern can only appear once.");
    }

    const names = groups.map((g) => g.name);
    if (new Set(names).size !== names.length) {
      throw new Error("Duplicate names are not allowed.");
    }

    return groups;
  }
}

Mapping
  = first:Group rest:(";" Group)* {
      return validateGroups([first, ...rest.map(([, group]) => group)]);
    }

Group
  = StarGroup
  / NonStarGroup

StarGroup = name:Name ":" "*" { return { name, pattern: null }; }

NonStarGroup = name:Name ":" pattern:RegexPattern { return { name, pattern }; }

Name = chars:[^:;]+ { return chars.join("").trim(); }

RegexPattern
  = pattern:[^;]+ {
      const patternString = pattern.join("").trim();
      return new RegExp(patternString);
    }
