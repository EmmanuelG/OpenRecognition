/*
Utilisation de la librairie HiVis (https://github.com/OliverColeman/hivis/tree/latest)
Installée via le gestionnaire de librairie (Sketch > Importer une librairire > Ajouter une librairie)
*/

import hivis.common.*;
import hivis.data.*;
import hivis.data.reader.*;
import hivis.data.view.*;

/* Hacking from the pie charts example of HiVis =^^=

Dans un premier temps on spécifie les tables qui vont servir à stocker/trier les données
On peut les voir dans la console.
La base de donnée entrante étant un tableau avec des lignes :
badge        | path      | lvl-1 | lvl-2 | lvl-3
compétence 1 | image.png |  lvl  |  lvl  |  lvl

Une première table pour l'avatar central
Une deuxième table pour le premier cercle (les savoirs-êtres / SE / sans niveaux)
Une troisième table pour le second cercle (les compétences / badges + leurs niveaux de savoir-théorique/procédural/pratique)
*/

DataTable data; // créer une table
DataTable avatar; // créer cette table
DataTable SEpath; // créer cette table
DataTable SElvl; // créer cette table
DataTable badgePath; // créer cette table
DataTable badgelvl; // créer cette table

/* Définission des variables, exemple : type_de_la_variable ESPACE nom_de_la_variable; */
boolean settingUp = true; // data is being (re)loaded and so the plot should not be drawn, yet
color[] palette = HVDraw.PASTEL8; // a nice colour palette to use
PImage imgBadge;  // https://processing.org/reference/PImage.html
PImage imgAvatar; // autre variable de type image

/* SETUP : la partie qui mouline tout, avant la partie draw pour dessiner avec */
void setup() {
  size(1000, 1000);
  textSize(12);
  
  data = HV.loadSpreadSheet(HV.loadSSConfig().sourceFile(sketchFile("test1Db.xlsx")).headerRowIndex(0).rowIndex(1)); // Get data from spreadsheet. 
  DataTable path = HV.newTable().addSeries(data.selectSeries(0)).addSeries(data.selectSeriesRange(1, 1)); // Get badge name and file path (with names as first series) from column 0 and 1 to 1
  DataTable lvl = HV.newTable().addSeries(data.selectSeries(0)).addSeries(data.selectSeriesRange(2, 4)); // Get knowledge level (with names as first series) from column 0 and 2 to 4
  
  // Split into center, soft skills and skills subsets.
  avatar = path.selectRows(0);
  println("\navatar:\n" + avatar);
  imgAvatar = loadImage(avatar.get(1).get(0).toString()); // Load the image into the program from the avatar subset (180 to 200px recommended)
  
  SEpath = path.selectRowRange(3, 10);
  SElvl = lvl.selectRowRange(3, 10);
  println("\nSEpath:\n" + SEpath);
  println("\nSElvl:\n" + SElvl);
  
  badgePath = path.selectRowRange(16, 32);
  badgelvl = lvl.selectRowRange(16, 32);
  println("\nbadgePath:\n" + badgePath);
  println("\nbadgelvl:\n" + badgelvl);
  
  settingUp = false;
}
/* Fin du bloc SETUP */


/* DRAW-1 : on commence à mettre tout ça en forme */
void draw() {
  background(255); // fond blanc
  noStroke(); // sans contours
  
  if (!settingUp) {
    // Légende des couleurs
    // ToDo : supprimer la partie avec variable et boucle comme il n'y a que trois couleurs au lieu des nombreuses de l'exemple pieInPieinPie.
    textAlign(LEFT, TOP);
    textSize(14);
    for (int c = 2; c < 5; c++) { // ici pour régler l'intervalle à afficher c=0 pour le début et c < 6 pour la fin
      fill(64); // gris fonçé (à la place de [palette]c+2)
      int y = c * 20;
      if (c >= 2) y -= 40; // remonter les blocs de 40 soit 2 blocs de 20 pour compenser le non-affichage des 3 premiers blocs
      rect(0, y, 40, 20);
      
      // Get the label from the original data table.
      String label = data.getSeriesLabel(c);
      label = label.replace("%", "").trim(); // Get rid of the % sign and remaining spaces.
      text(label, 45, y);
      text("(de 1 à 4)", 175, y);
    }

    fill(200); // gris clair
    rect(0, 0, 40, 20); // couleur savoir-théorique
    fill(150); // gris moyen
    rect(0, 20, 40, 20); // couleur savoir-procédural
    fill(100); // gris fonçé
    rect(0, 40, 40, 20); // couleur savoir-pratique
    
    // Point central
    int diameter = round(height * 0.24); // diamètre
    int xCenter = width / 2; // position
    int yCenter = height / 2; // position
    
    // Avatar central
    drawAvatar(avatar, 0, diameter, xCenter, yCenter); // méthode de dessin
    int avatarCenterX = imgAvatar.width/2; // afficher l'avatar au centre X
    int avatarCenterY = imgAvatar.height/2; // afficher l'avatar au centre Y
    image(imgAvatar, xCenter - avatarCenterX, yCenter - avatarCenterY); // image au centre
        
    // 222 Anneau des savoir-être
    float ringRadius = diameter; // The radius of the circle of badges
    float pieSize = diameter * 0.5;
    for (int p = 0; p < SEpath.length(); p++) { // The badges are distributed evenly in a circle around the centre.
      // First determine the angle (relative to horizontal, in radians) from the centre of window to where we want to put badges
      //float angle = (p - 1 * PI) / SEpath.length();
      float angle = (p * TWO_PI) / SEpath.length();
      // We use trigonometry to determine the position of badges p, relative to the centre of the window. 
      float x = xCenter + sin(angle) * ringRadius;
      float y = yCenter + cos(angle) * ringRadius;
      drawAroundImage(SEpath, SElvl, p, pieSize, x, y); // méthode de dessin 2, avec jeux de data des tables SE
      }
    fill(0, 0, 0, 95); // color
    textSize(24);
    text("Savoir-être", xCenter, yCenter - ringRadius - pieSize + 200); // texte et position
    textSize(14);
    
    // 333 Anneau des compétences
    ringRadius = diameter * 1.725; // The radius of the circle of badges
    for (int p = 0; p < badgePath.length(); p++) { // The badges are distributed evenly in a circle around the centre.
    //to spin it around X spots if you want an item at the bottom
    //float angle = ((p - X) * TWO_PI) / badgePath.length();
      float angle = (p * TWO_PI) / badgePath.length();
      float x = xCenter + sin(angle) * ringRadius;
      float y = yCenter + cos(angle) * ringRadius;
      drawAroundImage(badgePath, badgelvl, p, pieSize, x, y); // méthode de dessin 2, avec jeux de data des tables badges
      }
    fill(0, 0, 0, 95);
    textSize(24);
    text("Compétences", xCenter, yCenter - ringRadius - pieSize + 200);
    textSize(14);
    
/*    // Le reste
    ringRadius = diameter * 2.25; // The radius of the circle of badges
    for (int p = 0; p < badgePath.length(); p++) { // The badges are distributed evenly in a circle around the centre.
    //to spin it around X spots if you want an item at the bottom
    float angle = ((p - 0.5) * TWO_PI) / badgePath.length();
    //float angle = (p * TWO_PI) / badgePath.length();
      float x = xCenter + sin(angle) * ringRadius;
      float y = yCenter + cos(angle) * ringRadius;
      fillBackground(badgePath, p, x, y); // méthode de dessin 3, avec jeux de data des tables badges
      }*/
  }
}
/* Fin DRAW */

/* fonction drawAvatar */
void drawAvatar(DataTable path, int row, float diameter, float x, float y) {
  //Afficher l'image
  //image(imgAvatar, x - img.width/4, y - img.width/4, img.width/2, img.height/2);

  // Anneau
  fill(1); // color-1, black
  ellipse(x, y, diameter, diameter); // shape-1
  fill(255); // color-2, white
  ellipse(x, y, diameter * 0.9, diameter * 0.9); // shape-2, smaller, to look like a ring

  // Draw label
  fill(64); // text color grey
  textAlign(CENTER, TOP);
  text(path.get(0).get(row).toString(), x, y + diameter / 2);
} // Fin drawAvatar

/* fonction drawAroundImage, dessine chaque badge selon les valeurs du tableau */
void drawAroundImage(DataTable path, DataTable lvl, int row, float diameter, float x, float y) {
  //HVDraw.pie(this, lvl.getRow(row), diameter, x, y, palette, 2); // draw the pie

  //arc(x, y, diameter, diameter, angle start, angle stop) détail de la fonction arc() l'angle est en radian (et 2PI=360°)
  float segment = (TWO_PI/12); // un cercle divisé en 3 tiers (les trois savoirs) eux-même divisés en 4 niveaux (cf le CNAM) soit 12 segments

  //println(lvl.get(1).get(row).getClass() ); // commande pour vérifier la classe de ce qui sort du tableau dans la console (i.e. : double)
  double lvl1 = (double) lvl.get(1).get(row); // nécessité de confirmer/convertir la donnée du tableau en double (float avec plus de décimales) bien qu'elle soit déjà de ce type
  float lvl1_float = (float) lvl1; // puis conversion en float pour usage dans la fonction arc
  double lvl2 = (double) lvl.get(2).get(row); // idem mais pour le niveau savoir-procédural
  float lvl2_float = (float) lvl2;
  double lvl3 = (double) lvl.get(3).get(row); // idem mais pour le niveau savoir-faire
  float lvl3_float = (float) lvl3;
    
  fill(200); // gris clair tier 1
  arc(x, y, diameter, diameter, segment*0, segment * lvl1_float ); // tier 1 théorie, angle de fin position 1 à 4
  fill(150); // gris moyen tier 2
  arc(x, y, diameter, diameter, segment*4, segment * lvl2_float ); // tier 2 procédural, angle de fin position 4 à 8
  fill(100); // gris fonçé tier 3
  arc(x, y, diameter, diameter, segment*8, segment * lvl3_float ); // tier 3 pratique, angle de fin position 8 à 12
    
  fill(255); // blanc
  ellipse(x, y, diameter * 0.90, diameter * 0.90); // circle, smaller, to look like a ring
  
  imgBadge = loadImage(path.get(1).get(row).toString() );  // charger l'image depuis le chemin donné dans la colonne du tableau, sous-ensemble path (180 to 200px recommended)
  image(imgBadge, x - imgBadge.width/4, y - imgBadge.width/4, imgBadge.width/2, imgBadge.height/2); // afficher l'image chargée
  // Draw label
  fill(64);
  textAlign(CENTER, TOP);
  text(path.get(0).get(row).toString(), x, y + diameter / 2);
} // Fin drawAroundImage

/* fonction fillBackground, dessine le reste du fond */
void fillBackground(DataTable path, int row, float x, float y) {
  imgBadge = loadImage(path.get(1).get(row).toString() );  // charger l'image depuis le chemin donné dans la colonne du tableau, sous-ensemble path (180 to 200px recommended)
  image(imgBadge, x - imgBadge.width/4, y - imgBadge.width/4, imgBadge.width/2, imgBadge.height/2); // afficher l'image chargée
} // Fin fillBackground