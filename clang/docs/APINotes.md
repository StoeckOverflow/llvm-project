# API Notes: Annotations Without Modifying Headers

**The Problem:** You have headers you want to use, but you also want to add
extra information to the API. You don't want to put that information in the
headers themselves --- perhaps because you want to keep them clean for other
clients, or perhaps because they're from some open source project and you don't
want to modify them at all.

**Incomplete solution:** Redeclare all the interesting parts of the API in your
own header and add the attributes you want. Unfortunately, this:

- doesn't work with attributes that must be present on a definition
- doesn't allow changing the definition in other ways
- requires your header to be included in any client code to take effect

**Better solution:** Provide a "sidecar" file with the information you want to
add, and have that automatically get picked up by the module-building logic in
the compiler.

That's API notes.

API notes use a YAML-based file format. YAML is a format best explained by
example, so here is a [small example](https://github.com/llvm/llvm-project/blob/main/clang/test/APINotes/Inputs/Frameworks/SomeKit.framework/Headers/SomeKit.apinotes)
from the compiler test suite of API
notes for a hypothetical "SomeKit" framework.

## Usage

API notes files are found relative to the module map that defines a module,
under the name "SomeKit.apinotes" for a module named "SomeKit". Additionally, a
file named "SomeKit_private.apinotes" will also be picked up to go with a
private module map. For bare modules these two files will be in the same
directory as the corresponding module map; for framework modules, they should
be placed in the Headers and PrivateHeaders directories, respectively. The
module map for a private top-level framework module should be placed in the
PrivateHeaders directory as well, though it does not need an additional
"_private" suffix on its name.

Clang will search for API notes files next to module maps only when passed the
`-fapinotes-modules` option.

## Limitations

- Since they're identified by module name, API notes cannot be used to modify
  arbitrary textual headers.

## "Versioned" API Notes

Many API notes affect how a C API is imported into Swift. In order to change
that behavior while still remaining backwards-compatible, API notes can be
selectively applied based on the Swift compatibility version provided to the
compiler (e.g. `-fapi-notes-swift-version=5`). The rule is that an
explicitly-versioned API note applies to that version *and all earlier
versions,* and any applicable explicitly-versioned API note takes precedence
over an unversioned API note.

## Reference

An API notes file contains a YAML dictionary with the following top-level
entries:

```{eval-rst}

:Name:

  The name of the module (the framework name, for frameworks). Note that this
  is always the name of a top-level module, even within a private API notes
  file.

  ::

    Name: MyFramework

:Classes, Protocols, Tags, Typedefs, Globals, Enumerators, Functions, Namespaces:

  Arrays of top-level declarations. Each entry in the array must have a
  'Name' key with its Objective-C or C++ name. "Tags" refers to structs,
  C++ classes, enums, and unions; "Classes" refers to Objective-C classes;
  "Enumerators" refers to enum cases.

  ::

    Classes:
    - Name: MyController
      …
    - Name: MyView
      …

:SwiftVersions:

  Contains explicit information for backwards compatibility. Each entry in
  the array contains a 'Version' key, which should be set to '4' for
  annotations that only apply to Swift 4 mode and earlier. The other entries
  in this dictionary are the same declaration entries as at the top level:
  Classes, Protocols, Tags, Typedefs, Globals, Enumerators, and Functions.

  ::

    SwiftVersions:
    - Version: 4
      Classes: …
      Protocols: …

Each entry under 'Classes' and 'Protocols' can contain "Methods" and
"Properties" arrays, in addition to the attributes described below:

:Methods:

  Identified by 'Selector' and 'MethodKind'; the MethodKind is either
  "Instance" or "Class".

  ::

    Classes:
    - Name: UIViewController
      Methods:
      - Selector: "presentViewController:animated:"
        MethodKind: Instance
        …

:Properties:

  Identified by 'Name' and 'PropertyKind'; the PropertyKind is also either
  "Instance" or "Class".

  ::

    Classes:
    - Name: UIView
      Properties:
      - Name: subviews
        PropertyKind: Instance
        …

Each entry under "Tags" can contain "Methods", "Fields", and nested "Tags"
arrays. Methods under Tags are C++ methods identified by 'Name' (rather than
'Selector' and 'MethodKind' as used for Objective-C methods).

:Methods (under Tags):

  Identified by 'Name'.

  ::

    Tags:
    - Name: MyClass
      Methods:
      - Name: doSomething
        …

Function-like entries under "Functions" and tag "Methods" can use
``Where.Parameters`` to select a specific overload by its ordinary explicit
function parameters. This selector is declaration-selection data and does not
change the annotation payload.

:Where.Parameters:

  When omitted, a function-like API notes entry is selected by name only. An
  explicitly empty list selects the zero-explicit-parameter overload, and a
  non-empty list selects an exact ordered parameter list.

  ::

    Functions:
    - Name: makeWidget
      Where:
        Parameters:
        - int
      SwiftName: makeWidget(_:)

    Tags:
    - Name: Widget
      Methods:
      - Name: reset
        Where:
          Parameters: []
        SwiftName: reset()

  Matching is based on the declaration's explicit function parameter list.
  Default arguments do not change the selector arity, and static C++ methods
  are matched by their explicit parameters.

  C++ template matching is outside this selector model. A template type that
  appears as an ordinary parameter type is treated as a parameter spelling.
  Future support may need to keep ordinary parameters, template parameter
  structure, and concrete template arguments separate. For example,
  ``Template.Parameters`` could describe the template parameter list,
  ``TemplateArguments`` could select a specialization such as ``f<int>``, and
  uses of template parameters in ``Where.Parameters`` may need structural
  identity such as depth and index rather than redeclaration-local names like
  ``T`` or ``P``.

  Mixed template and non-template overload sets may also need an additional
  declaration-identity layer so an entry can say whether it targets the primary
  template, a concrete specialization, or the non-template overload. Template
  parameters must also remain separate from ordinary function parameters: a
  function template such as ``template <typename P> void f()`` has no explicit
  function parameters, so ``Where.Parameters: []`` would still describe the
  ordinary function parameter list, not the template parameter list.

  Redeclarations of the same function template may use different local template
  parameter names, such as ``template <typename T> void f(T)`` followed by
  ``template <typename P> void f(P)``. Future matching for dependent parameter
  types should therefore use structural template parameter identity rather than
  treating ``T`` and ``P`` as distinct selector spellings.

  Dependent parameter types add another layer: the template parameter might be
  part of a larger type spelling rather than the whole parameter type. Examples
  include ``template <typename T> void f(const T&)``,
  ``template <typename Container> void f(const typename
  Container::value_type&)``, and ``template <typename Key, typename Value> void
  f(const std::pair<Key, Value>&)``.

  One possible design would match the concrete source name of the template
  parameter, but this is tied to declaration-local names and would not work well
  for shared API notes that need to cover library implementations with
  different template parameter naming conventions. Another design would use
  placeholders directly in parameter spellings, such as
  ``const _TemplateParam(0, 0)&``. That keeps the structural identity explicit,
  but makes the spelling less natural.

  A more readable future direction is to introduce API-notes-local names for
  structurally identified template parameters, then use those names in
  ``Where.Parameters`` spellings:

  ::

    Functions:
    - Name: f
      TemplateParameters:
      - Name: T
        Depth: 0
        Index: 0
      Where:
        Parameters:
        - const T&

    - Name: f
      TemplateParameters:
      - Name: Container
        Depth: 0
        Index: 0
      Where:
        Parameters:
        - const Container::value_type&

    - Name: f
      TemplateParameters:
      - Name: Key
        Depth: 0
        Index: 0
      - Name: Value
        Depth: 0
        Index: 1
      Where:
        Parameters:
        - const std::pair<Key,Value>&

  Here, ``Name`` would be API-notes-local notation rather than the source
  template parameter name. ``Depth`` and ``Index`` would provide the structural
  identity used for matching, so redeclarations that use different local names
  could still be matched consistently.

  Questions such as default template arguments, non-type template parameters,
  template-template parameters, parameter packs, alias equivalence, and whether
  primary templates or only concrete instantiations are matched remain future
  design work. The following syntax is illustrative and rejected by current API
  notes:

  ::

    Functions:
    - Name: f
      Template:
        Parameters:
        - Kind: type
      Where:
        TemplateArguments:
        - int
        Parameters:
        - TemplateParameter:
            Depth: 0
            Index: 0

:Fields:

  Identified by 'Name'.

  ::

    Tags:
    - Name: MyStruct
      Fields:
      - Name: value
        Nullability: O
        …

:Tags (nested):

  Nested tags follow the same schema as top-level Tags entries.

  ::

    Tags:
    - Name: OuterClass
      Tags:
      - Name: InnerClass
        …

Each declaration supports the following annotations (if relevant to that
declaration kind), all of which are optional:

:SwiftName:

  Equivalent to ``NS_SWIFT_NAME``. For a method, must include the full Swift name
  with all arguments. Use "_" to omit an argument label.

  ::

    - Selector: "presentViewController:animated:"
      MethodKind: Instance
      SwiftName: "present(_:animated:)"

    - Class: NSBundle
      SwiftName: Bundle

:SwiftImportAs:

  For a class, possible values are ``owned`` (equivalent to
  ``SWIFT_SELF_CONTAINED``) or ``reference`` (equivalent to
  ``SWIFT_SHARED_REFERENCE``, also requires specifying ``SwiftReleaseOp`` and
  ``SwiftRetainOp``).

  For a method, possible values are ``unsafe`` (equivalent
  to ``SWIFT_RETURNS_INDEPENDENT_VALUE``) or ``computed_property`` (equivalent to
  ``SWIFT_COMPUTED_PROPERTY``).

  ::

    Tags:
    - Name: OwnedStorage
      SwiftImportAs: owned

:SwiftRetainOp, SwiftReleaseOp:

  Controls the lifetime operations of a class which uses custom reference
  counting. The class must be annotated as a reference type using
  ``SwiftImportAs: reference``. The values are either names of global functions,
  each taking a single parameter of a pointer type, or ``immortal`` for a type
  that is considered alive for the duration of the program.

  ::

    Tags:
    - Name: RefCountedStorage
      SwiftImportAs: reference
      SwiftReleaseOp: RCRelease
      SwiftRetainOp: RCRetain
    - Name: ImmortalSingleton
      SwiftImportAs: reference
      SwiftReleaseOp: immortal
      SwiftRetainOp: immortal

:SwiftCopyable:

  Allows annotating a C++ class as non-copyable in Swift. Equivalent to
  ``SWIFT_NONCOPYABLE``, or to an explicit conformance ``: ~Copyable``.

  ::

    Tags:
    - Name: tzdb
      SwiftCopyable: false

  A non-copyable type can have a "destroy" operation, specified with
  `SwiftDestroyOp`, which will be invoked on the instance when it is no
  longer in use to free up resources.

  ::

    Tags:
    - Name: WGPUAdapterInfo
      SwiftCopyable: false
      SwiftDestroyOp: wgpuAdapterInfoFreeMembers

:SwiftConformsTo:

  Allows annotating a C++ class as conforming to a Swift protocol. Equivalent
  to ``SWIFT_CONFORMS_TO_PROTOCOL``. The value is a module-qualified name of a
  Swift protocol.

  ::

    Tags:
    - Name: vector
      SwiftConformsTo: Cxx.CxxSequence

:SwiftSafety:

  Import a declaration as ``@safe`` or ``@unsafe`` to Swift.

  ::

    Tags:
    - Name: UnsafeType
      SwiftSafety: unsafe
    - Name: span
      Methods:
        - Name: size
          SwiftSafety: safe

:Availability, AvailabilityMsg:

  A value of "nonswift" is equivalent to ``NS_SWIFT_UNAVAILABLE``. A value of
  "available" can be used in the "SwiftVersions" section to undo the effect of
  "nonswift".

  ::

    - Selector: "dealloc"
      MethodKind: Instance
      Availability: nonswift
      AvailabilityMsg: "prefer 'deinit'"

:SwiftPrivate:

  Equivalent to NS_REFINED_FOR_SWIFT.

  ::

    - Name: CGColorEqualToColor
      SwiftPrivate: true

:Nullability:

  Used for properties and globals. There are four options, identified by their
  initials:

  - ``Nonnull`` or ``N`` (corresponding to ``_Nonnull``)
  - ``Optional`` or ``O`` (corresponding to ``_Nullable``)
  - ``Unspecified`` or ``U`` (corresponding to ``_Null_unspecified``)
  - ``Scalar`` or ``S`` (deprecated)

  Note that 'Nullability' is overridden by 'Type', even in a "SwiftVersions"
  section.

  .. note::

    'Nullability' can also be used to describe the argument types of methods
    and functions, but this usage is deprecated in favor of 'Parameters' (see
    below).

  ::

    - Name: dataSource
      Nullability: O

:NullabilityOfRet:

  Used for methods and functions. Describes the nullability of the return type.

  Note that 'NullabilityOfRet' is overridden by 'ResultType', even in a
  "SwiftVersions" section.

  .. warning::

    Due to a compiler bug, 'NullabilityOfRet' may change nullability of the
    parameters as well (rdar://30544062). Avoid using it and instead use
    'ResultType' and specify the return type along with a nullability
    annotation (see documentation for 'ResultType').

  ::

    - Selector: superclass
      MethodKind: Class
      NullabilityOfRet: O

:Type:

  Used for properties and globals. This completely overrides the type of the
  declaration; it should ideally only be used for Swift backwards
  compatibility, when existing type information has been made more precise in a
  header. Prefer 'Nullability' and other annotations when possible.

  We parse the specified type as if it appeared at the location of the
  declaration whose type is being modified.  Macros are not available and
  nullability must be applied explicitly (even in an ``NS_ASSUME_NONNULL_BEGIN``
  section).

  ::

    - Name: delegate
      PropertyKind: Instance
      Type: "id"

:ResultType:

  Used for methods and functions. This completely overrides the return type; it
  should ideally only be used for Swift backwards compatibility, when existing
  type information has been made more precise in a header.

  We parse the specified type as if it appeared at the location of the
  declaration whose type is being modified.  Macros are not available and
  nullability must be applied explicitly (even in an ``NS_ASSUME_NONNULL_BEGIN``
  section).

  ::

    - Selector: "subviews"
      MethodKind: Instance
      ResultType: "NSArray * _Nonnull"

:SwiftImportAsAccessors:

  Used for properties. If true, the property will be exposed in Swift as its
  accessor methods, rather than as a computed property using ``var``.

  ::

    - Name: currentContext
      PropertyKind: Class
      SwiftImportAsAccessors: true

:NSErrorDomain:

  Used for ``NSError`` code enums. The value is the name of the associated
  domain ``NSString`` constant; an empty string (``""``) means the enum is a
  normal enum rather than an error code.

  ::

    - Name: MKErrorCode
      NSErrorDomain: MKErrorDomain

:SwiftWrapper:

  Controls ``NS_STRING_ENUM`` and ``NS_EXTENSIBLE_STRING_ENUM``. There are three
  options:

  - "struct" (extensible)
  - "enum"
  - "none"

  Note that even an "enum" wrapper is still presented as a struct in Swift;
  it's just a "more enum-like" struct.

  ::

    - Name: AVMediaType
      SwiftWrapper: none

:EnumKind:

  Has the same effect as ``NS_ENUM`` and ``NS_OPTIONS``. There are four options:

  - "NSEnum" / "CFEnum"
  - "NSClosedEnum" / "CFClosedEnum"
  - "NSOptions" / "CFOptions"
  - "none"

  ::

    - Name: GKPhotoSize
      EnumKind: none

:Parameters:

  Used for methods and functions. Parameters are identified by a 0-based
  'Position' and support the 'Nullability', 'NoEscape', and 'Type' keys.

  .. note::

    Using 'Parameters' within a parameter entry to describe the parameters of a
    block is not implemented. Use 'Type' on the entire parameter instead.

  ::

    - Selector: "isEqual:"
      MethodKind: Instance
      Parameters:
      - Position: 0
        Nullability: O

:NoEscape:

  Used only for block parameters. Equivalent to ``NS_NOESCAPE``.

  ::

    - Name: dispatch_sync
      Parameters:
      - Position: 0
        NoEscape: true

:SwiftBridge:

  Used for Objective-C class types bridged to Swift value types. An empty
  string ("") means a type is not bridged. Not supported outside of Apple
  frameworks (the Swift side of it requires conforming to implementation-detail
  protocols that are subject to change).

  ::

    - Name: NSIndexSet
      SwiftBridge: IndexSet

:SwiftReturnOwnership:

  Used for methods and functions. Specifies the ownership convention for the
  return value when it is a foreign reference type (a type imported as
  ``SwiftImportAs: reference``). Possible values are:

  - ``retained`` --- the caller receives an owned reference
    (equivalent to ``__attribute__((swift_attr("returns_retained")))``).
  - ``unretained`` --- the caller receives an unowned reference
    (equivalent to ``__attribute__((swift_attr("returns_unretained")))``).

  ::

    Functions:
    - Name: createRefCounted
      SwiftReturnOwnership: retained
    - Name: getSharedRefCounted
      SwiftReturnOwnership: unretained
    Tags:
    - Name: ImmortalRefType
      SwiftImportAs: reference
      Methods:
      - Name: createChild
        SwiftReturnOwnership: retained

:DesignatedInit:

  Used for init methods. Equivalent to ``NS_DESIGNATED_INITIALIZER``.

  ::

    - Selector: "initWithFrame:"
      MethodKind: Instance
      DesignatedInit: true
```
