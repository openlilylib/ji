%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% This file is part of openLilyLib,                                           %
%                      ===========                                            %
% the community library project for GNU LilyPond                              %
% (https://github.com/openlilylib)                                            %
%                                                                             %
% Library: ji                                                                 %
%          ==                                                                 %
%                                                                             %
% openLilyLib is free software: you can redistribute it and/or modify         %
% it under the terms of the GNU General Public License as published by        %
% the Free Software Foundation, either version 3 of the License, or           %
% (at your option) any later version.                                         %
%                                                                             %
% openLilyLib is distributed in the hope that it will be useful,              %
% but WITHOUT ANY WARRANTY; without even the implied warranty of              %
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               %
% GNU General Public License for more details.                                %
%                                                                             %
% You should have received a copy of the GNU General Public License           %
% along with openLilyLib. If not, see <http://www.gnu.org/licenses/>.         %
%                                                                             %
% openLilyLib is maintained by Urs Liska, ul@openlilylib.org                  %
% and others.                                                                 %
%       Copyright Urs Liska, 2016                                             %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\version "2.19.50"


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Configuration

% Change the fundamental, active for following notes
jiFundamental =
#(define-void-function (fund) (ly:pitch?)
   (setOption '(ji state fundamental) fund))


% Map the semitone returned by ratio->step-deviation
% to a LilyPond pitch definition.
% This is based on the middle c and has to be transposed later
% TODO:
% Make this work with alternative scales as well.
% That should be based on the option ji.conf.steps-per-whole-tone.
#(define (steps->pitch semitone)
   (let
     ;; two lists defining the 12 steps within the octave
     ;;       c  cis  d  dis  e  f  fis  g  as   a  bes   b
    ((steps '(0  0    1  1    2  3  3    4  4    5  6     6))
     (semis '(0  1/2  0  1/2  0  0  1/2  0  1/2  0  -1/2  0))
     ;; strip semitons of octave
     (index (modulo semitone 12)))
     (ly:make-pitch
      (floor (/ semitone 12))
      (list-ref steps index)
      (list-ref semis index))))

% Local predicate which is necessary to process two optional arguments
#(define (pitch-or-dur? obj)
   (or (ly:pitch? obj)
       (ly:duration? obj)))

