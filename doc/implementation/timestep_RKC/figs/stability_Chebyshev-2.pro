;;;;;;;;;;;;;;;;;;;;;;;;;
;;;   Chebyshev.pro   ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;;  Author: wd (wdobler [at] gmail [dot] com)
;;;  Date:   18-Aug-2008
;;;
;;;  Description:
;;;    Plot a few (shifted and scaled) Chebyshev polynomials for
;;;    second-order schemes

L = 18
x = linspace(0,L)
yrange = [-1,1]*1.5

loadct, 5
blue = 50
orange = 150
red = 120
orange = 140
yellow = 185
dashed = 2

if (!d.name eq 'PS') then begin
  DEVICE, XSIZE=18, YSIZE=4.5, $
      XOFFSET=3
  device, /COLOR
endif
aspect_ratio = aspect_pos(minmax(yrange, /RANGE) / L, $
                          MARGIN=[0.1, 0.03, 0.25, 0.03])

plot, x, exp(-x), $
      YRANGE=yrange, XSTYLE=1, YSTYLE=3, $
      POS=aspect_ratio, $
      XTITLE='!3Cou!X', $
      YTITLE='!8A!3(Cou)!X'
ophline, [-1, 0, 1]

oplot, COLOR=blue  , x, 1 - x + x^2/2.
oplot, COLOR=red   , x, 1 - x + x^2/2. - x^3/16.
oplot, COLOR=orange, x, 1 - x + x^2/2. - 2./25.*x^3 + 1./250*x^4
oplot, COLOR=yellow, x, 1 - x + x^2/2. - 7./80.*x^3 + 1./160.*x^4 - 1./6400.*x^5


end
; End of file Chebyshev.pro
