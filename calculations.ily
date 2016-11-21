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
% Underlying mathematics

% Convert a ratio to a floating point octave representation.
% A ratio of 2/1 will result in one octave (= 1), 4/1 in two octaves etc.
% Different representations such as semitones or cents should be calculated
% from here.
#(define (ratio->octaves ratio)
   (/ (log ratio) (log 2)))

% Convert a ratio to a floating point step representation.
% The integer part is the number of semitones above the fundamental,
% the fractional part is the fraction of a semitone
#(define (ratio->steps ratio)
   (* (* 6 (getOption '(ji conf steps-per-whole-tone)))
     (ratio->octaves ratio)))

% Convert a ratio and return a pair with
% - the pitch in semitones
% - the cent deviation above or below (rounded)
% Rounds to the nearest semitone and gives the deviation
% in cents -49 < cent < 49.
#(define (ratio->step/cent ratio)
   (let*
    ((step-cent (ratio->steps ratio))
     ;; truncate the floating point number to the nearest integer (scale step)
     (step (inexact->exact (round step-cent)))
     ;; determine the cent deviation and truncate to an integer
     (cent (inexact->exact (round (* 100 (- step-cent step))))))
    (cons step cent)))
