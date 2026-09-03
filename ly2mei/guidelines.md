# Transcription Guidelines

## Voice codes

Polyphonic voices are encoded according to the following mapping:

| Voice Name  | Alternative Name | Code |
| --- | --- |
| Cantus | Canto, Superius | c |
| Altus | Alto, Contratenor |  a |
| Tenor | Tenore | t |
| Bassus | Basso | b |
| Quintus | Quinto, Quinta Vox | q |
| Sextus | Sesto, Sexta Vox | sx |
| Septimus | Settimo, Septima Vox | st |
| Octavus | Ottavo, Octava Vox | o |
| Full Score | | fs |
| Basso Continuo | Continuo | bc |
| Violino | Violin | vl |
| Cornetto | Zink | cr | 

Voices, like "Cantus II" or "Bassus I" are encoded y adding an integer after the code, giving "c2" and "b1" respectively.

## Music & Lyrics

Musical and lyrics context is store in two separate Lilypond files, with suffix "\_music" and "\_lyrics" respectively.

Music transcriptions use the `\relative` notation for pitches.

Lyrics uses the standard `\lyricmode`. Notes without syllables are skipped via the `\skip4` element.

## 


## Diplomatic edition

Each partbook is presented in a diplomatic editon, respecting all original notes, lyrics and eventual printing mistakes, and a performance edition with needed adustments and modernizations.

### Clefs

In lilypond [clefs](https://lilypond.org/doc/v2.24/Documentation/notation/clef-styles) are encoded via the `\clef` element followed by a string. For our project we will use the "petrucci" style clefs. For example, a lilypond `\clef "petrucci-c2` will be converted in the MEI element `<staffDef>` with attributes `clef.shape="G" clef.line="2"`. 

### Key Signatures

In lilypond you can encode a key signature by using the element `\key` followed by the desidered pitch and the `\major` or `\minor` scales. For example, a piece with one flat on the signature will be `\key f \major` in lilypond notation, while in MEI we will have `<keySign pname="f" mode="major">`.

### Time Signatures and Proportion Signs

In lilypond we don't have a dedicated way to encode [mensural time signatures](https://lilypond.org/doc/v2.23/Documentation/notation/typesetting-mensural-music#mensural-time-signatures): in order to encode them the language relies on modern time signature notation.

| Lilypond | MEI |
| --- | --- |
| `\time 2/2` | `<mensur sign="C" tempus="2 slash="1">` |
| `\time 4/4` | `<mensur sign="C" tempus="2 slash="1">` |
| `\tripla` | `<mensur num="3">` |
|`\sesquialtera` | `<mensur num="3" numbase="2">` |

Use `\hiddenTime \time x/y` to revert to the implicit mensuration of the piece after a proportion.


For example, if you wish to encode cut tempus imperfectum you have to use `\time 2/2`, while in MEI you would write `<mensur sign="C" tempus="2" slash="1">`.

Sequialtera and Tripla proportions are not covered in Lilypond, while in MEI are simply encoded as `<mensur num="3" numbase="2"> ` and `<mensur num="3">` respectively.

My custom solution is to use Lilypond's `\musicglyph` elements inside a markup on a silent element `s4-\tweak extra-offset #'(0 . -3.5) ^\markup{ \musicglyph #"three"}` for the Tripla and `s4-\tweak extra-offset #'(0 . -5.5) ^\markup{ \column{ \musicglyph #"three" \musicglyph #"two"} }` for the Sesquialtera.

### Alteration

No musica ficta will be provided, trying to be faithful to the actual notation. Alteration on the page are always followed by a `!` sign in the Lilypond notation. Sharp signs intended as a natural one, like on a B are encoded as `bs!` even if its meaning is `b!`.

In the performance edition, suggested alterations are indicated via the `\ficta` custom command, placing the alteration above the note.
