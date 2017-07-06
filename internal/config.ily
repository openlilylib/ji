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


\version "2.19.51"

% Show cent deviation for note (##t)
\registerOption ji.show.cent ##f

% Show ratio for note (##t)
\registerOption ji.show.ratio ##f

% Print the fundamental pitch (##f)
\registerOption ji.show.fundamental ##f

% Print the target pitch (##t)
\registerOption ji.show.notehead ##t

% Display resulting note with harmonics note head
\registerOption ji.show.notehead-style #'default

\registerOption ji.conf.use-color ##f

% Maintain the current fundamental and duration, behaviour
% similar to regular notes. Make them default to LilyPond's
% note defaults (middle c and quarter note).
% NOTE: This is completely monophonic as the data is maintained
% in these global options. Any kind of polyphonic behaviour has
% yet to be implemented.
\registerOption ji.state.fundamental #(ly:make-pitch 0 0 0)
\registerOption ji.state.duration 4

% Define what scale is the base for displaying pitches.
% Default is the chromatic scale, defined by 2 (whole tone / 2 = semitone).
% For a quarter tone scale one would set this option to 4
% NOTE: Anything except 2 is not supported yet.
\registerOption ji.conf.steps-per-whole-tone 2

% Necessary to use cross staff stems with fundamental/result notation
\registerOption ji.conf.use-cross-staff ##f

% If cross-staff notation is active this is the name of the upper staff
% where the target pitch is printed.
% It is up to the user to create such a staff context and keep it alive.
\registerOption ji.conf.cross-stuff.upper-name "ji-upper"

useCrossStaff =
#(define-scheme-function ()()
   (setOption '(ji conf use-cross-staff) #t)
   #{
     \layout {
       \context {
         \PianoStaff
         \consists #Span_stem_engraver
       }
     }
   #})



