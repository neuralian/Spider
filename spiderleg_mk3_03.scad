$fn = 256;

base_radius = 3.5;
tip_radius = 1;
eccentricity = 0.1;  // eccentricity of eliptical cross-section
seg_length = [25,35,40,25, 15]; 
nSegs = 5;

wall_thickness = 1;

joint_radius = base_radius*1.5;

joint_angle = [0 , -8, 25, 18, -12];
joint_direction = [0, -1, 1, 1, 1];  // 1 = spring above, -1 = spring below
joint_offset = 0;//base_radius/2;
joint_thickness = 0.5;

// derived parameters
joint_orientation = [ for (i=[0:nSegs-1]) cumsum(joint_angle, i)];
dy = [0, for (i=[0:nSegs-1]) -seg_length[i]*sin(joint_orientation[i])];
dz = [0, for (i=[0:nSegs-1]) seg_length[i]*cos(joint_orientation[i])];    
joint_pos = [ 0, for (i=[0:nSegs-1]) cumsum(seg_length, i)];
    
seg_base_radius = [ for (i = [1:nSegs]) 
         base_radius + (tip_radius-base_radius)*joint_pos[i-1]/joint_pos[nSegs]];
seg_tip_radius  = [ for (i = [1:nSegs]) 
         base_radius + (tip_radius-base_radius)*joint_pos[i]/joint_pos[nSegs] ];
    
seg_scale = [ for (i = [0:nSegs-1]) seg_tip_radius[i]/seg_base_radius[i]];
joint_scale = [for (i=[0:nSegs-1]) cumprod(seg_scale, i)];
    
module leg_segment(i) { // draw ith segment
 
    shell_shape = [ for (theta = [(360/$fn):(360/$fn):360]) seg_base_radius[i-1]*[(1-eccentricity)*cos(theta), sin(theta)] ];
 
  translate([0,cumsum(dy,i-1), cumsum(dz,i-1)])
  rotate([joint_orientation[i-1], 0, 0])
    linear_extrude(seg_length[i-1], scale = seg_scale[i-1]) 
    polygon(shell_shape, [0:($fn-1)], convexity = 10);
}




module leg() {
   

  // leg segments
  for (i = [1:nSegs-1]) {
    leg_segment(i);
    joint_spring(i);
  }
  leg_segment(nSegs);


}

module joint_spring(i) { // ith joint 
    
    this_joint_radius = joint_radius*joint_scale[i-1];
    this_joint_height = 2*leg_radius(cumsum(seg_length, i-1)-joint_radius*joint_scale[i-1])*(1-eccentricity);
    this_orientation = (joint_orientation[i-1]+joint_orientation[i])/2;
    this_centre_z = cumsum(dz,i);
    this_centre_y = cumsum(dy,i);
    
    translate([0, this_centre_y, this_centre_z])
    rotate([this_orientation,0,0])
    translate([0, joint_direction[i]*joint_offset*joint_scale[i-1], 0])
    rotate([90*(joint_direction[i]-1), 90, 0]) {
    cylinder(r = this_joint_radius, h = this_joint_height, center=true);
    translate([0, -this_joint_radius, 0])
      cube([2*this_joint_radius, 2*this_joint_radius,this_joint_height], center=true); 
    }
}

module joint_cut(i){
    
    this_cut_radius = joint_radius*joint_scale[i-1] - joint_thickness;
    this_cut_height = 2*leg_radius(cumsum(seg_length, i-1)-joint_radius*joint_scale[i-1])*(1-eccentricity)+2;
    this_orientation = (joint_orientation[i-1]+joint_orientation[i])/2;
    this_centre_z = cumsum(dz,i);
    this_centre_y = cumsum(dy,i);
    
    translate([0, this_centre_y, this_centre_z])
    rotate([this_orientation,0,0])
    translate([0, joint_direction[i]*joint_offset*joint_scale[i-1], 0])
    rotate([90*(joint_direction[i]-1), 90, 0])  {
    cylinder(r = this_cut_radius, h = this_cut_height, center=true);
    translate([0, -this_cut_radius-1, 0])
      cube([2*this_cut_radius, 2*this_cut_radius+2,this_cut_height], center=true);   
    }
    
}


module cutouts() {
    

    
    for (i=[1:nSegs-1]) {
        joint_cut(i);
     shell_shape = [for (theta = [(360/$fn):(360/$fn):360]) (1-eccentricity)*(1-wall_thickness/4)*seg_base_radius[i-1]*[cos(theta), sin(theta)] ];
  translate([0,cumsum(dy,i-1), cumsum(dz,i-1)])
  rotate([joint_orientation[i-1], 0, 0])
    translate([0,0, -1])
  linear_extrude(seg_length[i-1]+2, scale = seg_scale[i-1]) 
    polygon(shell_shape, [0:($fn-1)], convexity = 10);
    
    }
    
    
        // trim sides, so leg lies flat on printer bed
    cut_width = -cumsum(dy, nSegs);
    cut_height = cumsum(dz, nSegs);
    echo(cut_width);
    tol = 0.1;
    color([0,1,0]) 
    translate([(1-eccentricity)*base_radius+tol, -cut_width, 0])
    rotate([0, -atan((1-eccentricity)*(base_radius-tip_radius)/cumsum(dz, nSegs)), 0])
    cube([wall_thickness, 2*cut_width, cut_height]); 

    color([0,1,0]) 
    translate([-(1-eccentricity)*base_radius - wall_thickness-tol, -cut_width, 0])
    rotate([0, atan((1-eccentricity)*(base_radius-tip_radius)/cumsum(dz, nSegs)), 0])
    cube([wall_thickness, 2*cut_width, cut_height]); 
    
    
}


module joint_cuts() {
    
   // joint holes
   color([1, 0, 0]) 
  for (i=[1:nSegs]) {
      
      if (i<nSegs) {
   translate([-seg_base_radius[i]*(1-eccentricity),cumsum(dy,i), cumsum(dz,i)])
   rotate([0,90,0]) translate([0,0, -1])
       cylinder(r=joint_radius*joint_scale[i-1]-joint_thickness, h = 2*seg_base_radius[i]*(1-eccentricity)+2);
     
   cube_width = 2*joint_radius*joint_scale[i-1] - 2*joint_thickness;
   rot_angle = (joint_orientation[i-1]+joint_orientation[i])/2;
   ddy = 0.5*cube_width*cos(rot_angle);
   ddz = 0.5*cube_width*sin(rot_angle);
          
//          ddy = 0;
//          ddz = 0;
      
   translate([0,cumsum(dy,i)-ddy, cumsum(dz,i)-ddz])
   rotate([rot_angle,0,0])
   rotate([0,90,0]) 
       cube([cube_width, cube_width, 2*base_radius+2],
       center=true);    
      //    cylinder(r=cube_width/2, h = base_radius+2);
    
      

    
    shell_shape = [for (theta = [(360/$fn):(360/$fn):360]) (1-eccentricity)*(1-wall_thickness/4)*seg_base_radius[i-1]*[cos(theta), sin(theta)] ];
    
  translate([0,cumsum(dy,i-1), cumsum(dz,i-1)])
  rotate([joint_orientation[i-1], 0, 0])
    translate([0,0, -1])
  linear_extrude(seg_length[i-1]+2, scale = seg_scale[i-1]) 
    polygon(shell_shape, [0:($fn-1)], convexity = 10);
    
}
   
   
} 

    // trim sides, so leg lies flat on printer bed
    cut_width = cumsum(dz, nSegs);
    tol = -.5;
    color([0,1,0]) 
    translate([(1-eccentricity)*base_radius+tol, -cut_width, 0])
    rotate([0, -atan((1-eccentricity)*(base_radius-tip_radius)/cumsum(dz, nSegs)), 0])
    cube([wall_thickness, 2*cut_width, cut_width]); 

    color([0,1,0]) 
    translate([-(1-eccentricity)*base_radius - wall_thickness-tol, -cut_width, 0])
    rotate([0, atan((1-eccentricity)*(base_radius-tip_radius)/cumsum(dz, nSegs)), 0])
    cube([wall_thickness, 2*cut_width, cut_width]); 
    
}  // end joint cuts

function cumsum(v, n) = ( n==0 ? v[0] : v[n] + cumsum(v,n-1));
function cumprod(v,n) = ( n==0 ? v[0] : v[n] * cumprod(v,n-1));
function leg_radius(x) = base_radius + (tip_radius-base_radius)*x/joint_pos[nSegs];

//echo(joint_orientation);
//echo(dz);
//echo(dy);
//echo(seg_base_radius);
//echo(seg_tip_radius);
//echo(seg_scale);

rotate([0, 90+atan((1-eccentricity)*(base_radius-tip_radius)/cumsum(dz, nSegs)), 0])
translate([-(1-eccentricity)*base_radius, 0, 0])
difference() 
{
leg();
color([1,0,0]) cutouts();
}

//joint_spring(3);
//color([1,0,0]) joint_cut(3);
