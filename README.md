# GEOG0030 Geocomputation

This GitHub repository generates the GEOG0030 Geocomputation handbook, which can be found at: https://jtvandijk.github.io/GEOG0030

## Building this handbook

The handbook is built with [Quarto](https://quarto.org) `1.10.18` and R `4.6.1`.

```
quarto render --no-clean
```

`--no-clean` is required: a plain `quarto render` clears `docs/` before rendering, which would delete the archived year snapshots stored under `docs/<year>/`.

Package versions are listed in [REPRODUCIBILITY.md](REPRODUCIBILITY.md).

This work is licensed under a
[Creative Commons Attribution-ShareAlike 4.0 International License][cc-by-sa].

[![CC BY-SA 4.0][cc-by-sa-image]][cc-by-sa]

[cc-by-sa]: http://creativecommons.org/licenses/by-sa/4.0/
[cc-by-sa-image]: https://licensebuttons.net/l/by-sa/4.0/88x31.png
