%%% Main simulation code %%%

xing=imread('mpu.jpeg');   % 'xing' is the watermark image
zheng=imread('011.png');   % 'zheng' is the host image
zaoyin=0.05; % noise index
t1=10;
t2=10;


ori_watermark=im2gray(xing);
%ori_watermark_real=ori_watermark;
ori_watermark_real=imresize(ori_watermark,0.5);
% figure;
% imshow(ori_watermark_real);

cd=double(ori_watermark_real);
[h, w] = size(cd);
plane_1 = mod(cd, 2);
plane_2 = mod(floor(cd/2), 2);
plane_3 = mod(floor(cd/4), 2);
plane_4 = mod(floor(cd/8), 2);
plane_5 = mod(floor(cd/16), 2);
plane_6 = mod(floor(cd/32), 2);
plane_7 = mod(floor(cd/64), 2);
plane_8 = mod(floor(cd/128), 2);

plane_55=rot90(plane_5,1);
plane_555=rot90(plane_5,2);
plane_66=rot90(plane_6,1);
plane_666=rot90(plane_6,2);
plane_77=rot90(plane_7,1);
plane_777=rot90(plane_7,2);
plane_88=rot90(plane_8,1);
plane_888=rot90(plane_8,2);

% GTA_QBR processing
combine_1=[plane_8 plane_88;
           plane_5 plane_888]*1;
% figure;
% imshow(combine_1);

combine_2=[plane_55 plane_7;
           plane_777 plane_77]*1;
% figure;
% imshow(combine_2);
 combine_2_180=rot90(combine_2,0);
% figure;
% imshow(combine_2_180);

combine_3=[plane_1 plane_2;
           plane_3 plane_4]*1;
% figure;
% imshow(combine_3);

combine_4=[plane_666 plane_555;
           plane_66 plane_6]*1;
combine_4_180=rot90(combine_4,0);


% disp('----------carrier---------')
temp_host_image=zheng;
% temp_host_image=round(imresize(temp_host_image,0.5));
host_image=im2gray(temp_host_image);
% figure;
% imshow(host_image);
ccc=double(host_image);
[hc, wc] = size(ccc);
cc=ccc;
plane_1_host = mod(cc, 2);
plane_2_host = mod(floor(cc/2), 2);
plane_3_host = mod(floor(cc/4), 2);
plane_4_host = mod(floor(cc/8), 2);
plane_5_host = mod(floor(cc/16), 2);
plane_6_host = mod(floor(cc/32), 2);
plane_7_host = mod(floor(cc/64), 2);
plane_8_host = mod(floor(cc/128), 2);
% subplot(3, 3, 1);
% imshow(cc,[]);
% title('Original Image');
% subplot(3, 3, 2);
% imshow(plane_1_host);
% title('Bit Plane 1');
% subplot(3, 3, 3);
% imshow(plane_2_host);
% title('Bit Plane 2');
% subplot(3, 3, 4);
% imshow(plane_3_host);
% title('Bit Plane 3');
% subplot(3, 3, 5);
% imshow(plane_4_host);
% title('Bit Plane 4');
% subplot(3, 3, 6);
% imshow(plane_5_host);
% title('Bit Plane 5');
% subplot(3, 3, 7);
% imshow(plane_6_host);
% title('Bit Plane 6');
% subplot(3, 3, 8);
% imshow(plane_7_host);
% title('Bit Plane 7');
% subplot(3, 3, 9);
% imshow(plane_8_host);
% title('Bit Plane 8');


% Determining embedding rules
temp_plane_decision=zeros(hc,wc); % decision plane condition if sum of lsb7~lsb4>2
plane_embedding_lsb2=zeros(hc,wc);% embedding plane lsb2
plane_embedding_lsb1=zeros(hc,wc);% embedding plane lsb1
plane_embedding_lsb0=zeros(hc,wc);% embedding plane lsb0
for i=1:hc
    for j=1:wc
        if  plane_8_host(i,j)+plane_7_host(i,j)+plane_6_host(i,j)+...
                plane_5_host(i,j)+plane_4_host(i,j)>2
        temp_plane_decision(i,j)=1;
        end
        if  plane_8_host(i,j)+plane_7_host(i,j)+plane_6_host(i,j)+...
                plane_5_host(i,j)+plane_4_host(i,j)<=2
            temp_plane_decision(i,j)=0;
        end
        
    end
end

% Embedding 3-LSB
for i=1:hc
    for j=1:wc
        if temp_plane_decision(i,j)==0
           
            plane_embedding_lsb2(i,j)=1-combine_4_180(i,j);
        end
        if temp_plane_decision(i,j)==1
            
            plane_embedding_lsb2(i,j)=combine_4_180(i,j);
        end
    end
end
% figure;
% imshow(plane_embedding_lsb2);

% Embedding 2-LSB
for i=1:hc
    for j=1:wc
        if temp_plane_decision(i,j)==0
           
            plane_embedding_lsb1(i,j)=1-combine_2_180(i,j);
        end
        if temp_plane_decision(i,j)==1
            
            plane_embedding_lsb1(i,j)=combine_2_180(i,j);
        end
    end
end
% figure;
% imshow(plane_embedding_lsb1);

% Embedding 1-LSB
for i=1:hc
    for j=1:wc
        if temp_plane_decision(i,j)==0
            
            plane_embedding_lsb0(i,j)=1-combine_1(i,j);
        end
        if temp_plane_decision(i,j)==1
            
            plane_embedding_lsb0(i,j)=combine_1(i,j);
        end
    end
end
% figure;
% imshow(plane_embedding_lsb0);

% Generation of key image 'miyao'
miyao=zeros(512,512);
for i=1:hc
    for j=1:wc
        if temp_plane_decision(i,j)==combine_3(i,j)
            
            miyao(i,j)=0;
        end
        if temp_plane_decision(i,j)~=combine_3(i,j)
            
            miyao(i,j)=1;
        end
    end
end
miyao_show=uint8(miyao);
% figure;
% imshow(double(miyao_show));

% Generate the watermarked image
image_watermarked=zeros(h/2,w/2);% generate watermarked image
for i=1:hc
    for j=1:wc
        image_watermarked(i,j)=plane_8_host(i,j)*128+plane_7_host(i,j)*64+...
            plane_6_host(i,j)*32+plane_5_host(i,j)*16+plane_4_host(i,j)*8+...
            plane_embedding_lsb2(i,j)*4+plane_embedding_lsb1(i,j)*2+plane_embedding_lsb0(i,j)*1;
    end
end
image_watermarked_show=uint8(image_watermarked);

% figure;
% imshow(image_watermarked_show);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% Noise Attacks
 image_watermarked_show = imnoise(image_watermarked_show,'salt & pepper',zaoyin);
% noise_image = imnoise(image_watermarked_show,'gaussian',0.01,zaoyin);
% noise_image = imnoise(image_watermarked_show,'poisson');

% Cropping Attacks or Random Cropping
% image_watermarked_show(1:51,1:51)=0;    %1
% image_watermarked_show(1:114,1:114)=0; %5
% image_watermarked_show(1:161,1:161)=0;   %10
% image_watermarked_show(1:198,1:198)=0;   %15
image_watermarked_show(1:228,1:228)=0; %20
% image_watermarked_show(1:256,1:256)=0; %25
% image_watermarked_show(1:279,1:279)=0;%30
% image_watermarked_show(1:303,1:303)=0;%35
% image_watermarked_show(1:324,1:324)=0;%40

% noise_image =image_watermarked_show;
figure;
imshow(noise_image);

temp_noise_image=double(noise_image);
[hn, wn] = size(temp_noise_image);
cn=temp_noise_image;
plane_1_noise_image = mod(cn, 2);
plane_2_noise_image = mod(floor(cn/2), 2);
plane_3_noise_image = mod(floor(cn/4), 2);
plane_4_noise_image = mod(floor(cn/8), 2);
plane_5_noise_image = mod(floor(cn/16), 2);
plane_6_noise_image = mod(floor(cn/32), 2);
plane_7_noise_image = mod(floor(cn/64), 2);
plane_8_noise_image = mod(floor(cn/128), 2);


% Determine watermark extraction rules
plane_extrect_decision_lsb0=zeros(hc,wc);
plane_extrect_decision_lsb1=zeros(hc,wc);
plane_extrect_decision_lsb2=zeros(hc,wc);
temp_plane_decision_noise=zeros(hc,wc);
combine_3_extract=zeros(hc,wc);

% Extract watermark information from 1-LSB
for i=1:hc
    for j=1:wc
        
        if  plane_8_noise_image(i,j)+plane_7_noise_image(i,j)+plane_6_noise_image(i,j)+...
                plane_5_noise_image(i,j)+plane_4_noise_image(i,j)>2
        temp_plane_decision_noise(i,j)=1;
        if plane_1_noise_image(i,j)==0
            plane_extrect_decision_lsb0(i,j)=0;
        end
        if plane_1_noise_image(i,j)==1           
            plane_extrect_decision_lsb0(i,j)=1;
        end
        end
        if  plane_8_noise_image(i,j)+plane_7_noise_image(i,j)+plane_6_noise_image(i,j)+...
            plane_5_noise_image(i,j)+plane_4_noise_image(i,j)<=2
            temp_plane_decision(i,j)=0;
            if plane_1_noise_image(i,j)==0
            plane_extrect_decision_lsb0(i,j)=1;
            end
            if plane_1_noise_image(i,j)==1            
            plane_extrect_decision_lsb0(i,j)=0;
            end
        end
        
    end
end

% Extract watermark information from 2-LSB
for i=1:hc
    for j=1:wc
        if  plane_8_noise_image(i,j)+plane_7_noise_image(i,j)+plane_6_noise_image(i,j)+...
                plane_5_noise_image(i,j)+plane_4_noise_image(i,j)>2
        temp_plane_decision_noise(i,j)=1;
        if plane_2_noise_image(i,j)==0
            plane_extrect_decision_lsb1(i,j)=0;
        end
        if plane_2_noise_image(i,j)==1
            
            plane_extrect_decision_lsb1(i,j)=1;
        end
        end
        if  plane_8_noise_image(i,j)+plane_7_noise_image(i,j)+plane_6_noise_image(i,j)+...
                plane_5_noise_image(i,j)+plane_4_noise_image(i,j)<=2
            temp_plane_decision(i,j)=0;
            if plane_2_noise_image(i,j)==0
            plane_extrect_decision_lsb1(i,j)=1;
            end
            if plane_2_noise_image(i,j)==1
            
            plane_extrect_decision_lsb1(i,j)=0;
            end
        end
        
    end
end

% Extract watermark information from 3-LSB
for i=1:hc
    for j=1:wc
        if  plane_8_noise_image(i,j)+plane_7_noise_image(i,j)+plane_6_noise_image(i,j)+...
                plane_5_noise_image(i,j)+plane_4_noise_image(i,j)>2
        temp_plane_decision_noise(i,j)=1;
        if plane_3_noise_image(i,j)==0
            plane_extrect_decision_lsb2(i,j)=0;
        end
        if plane_3_noise_image(i,j)==1
            
            plane_extrect_decision_lsb2(i,j)=1;
        end
        end
        if  plane_8_noise_image(i,j)+plane_7_noise_image(i,j)+plane_6_noise_image(i,j)+...
                plane_5_noise_image(i,j)+plane_4_noise_image(i,j)<=2
            temp_plane_decision(i,j)=0;
            if plane_3_noise_image(i,j)==0
            plane_extrect_decision_lsb2(i,j)=1;
            end
            if plane_3_noise_image(i,j)==1
            
            plane_extrect_decision_lsb2(i,j)=0;
            end
        end
        
    end
end
% figure;
% imshow(plane_extrect_decision_lsb2);


for i=1:hc
    for j=1:wc
        if  plane_8_noise_image(i,j)+plane_7_noise_image(i,j)+plane_6_noise_image(i,j)+...
                plane_5_noise_image(i,j)+plane_4_noise_image(i,j)>2
        temp_plane_decision_noise(i,j)=1;
        if miyao(i,j)==0
            combine_3_extract(i,j)=1;
        end
        if miyao(i,j)==1
            combine_3_extract(i,j)=0;
        end
        end
        if  plane_8_noise_image(i,j)+plane_7_noise_image(i,j)+plane_6_noise_image(i,j)+...
                plane_5_noise_image(i,j)+plane_4_noise_image(i,j)<=2
            temp_plane_decision(i,j)=0;
         if miyao(i,j)==0
            combine_3_extract(i,j)=0;
        end
        if miyao(i,j)==1
            combine_3_extract(i,j)=1;
        end
        end
        
    end
end
% figure;
% imshow(plane_extrect_decision_lsb0);
% figure;
% imshow(plane_extrect_decision_lsb1);



% disp('----------image combined---------')
real_extrect_lsb2=rot90(plane_extrect_decision_lsb2,0);
real_extrect_lsb1=rot90(plane_extrect_decision_lsb1,0);
real_extrect_lsb0=plane_extrect_decision_lsb0;
% figure;
%  imshow(real_extrect_lsb2);
% figure;
% imshow(real_extrect_lsb1);

p_555=zeros(h,w);
p_666=zeros(h,w);
p_777=zeros(h,w);
p_888=zeros(h,w);%7887

p_55=zeros(h,w);
p_66=zeros(h,w);
p_77=zeros(h,w);
p_88=zeros(h,w);%5665

p_5=zeros(h,w);
p_6=zeros(h,w);
p_7=zeros(h,w);
p_8=zeros(h,w);%5678

p_11=zeros(h,w);
p_22=zeros(h,w);
p_33=zeros(h,w);
p_44=zeros(h,w);%1234

for i=1:hc
    for j=1:wc
        if i<=h && j<=w
            p_8(i,j)=real_extrect_lsb0(i,j);
            p_666(i,j)=real_extrect_lsb2(i,j);
            p_55(i,j)=real_extrect_lsb1(i,j);
            p_11(i,j)=combine_3_extract(i,j);
        end
         if i<=h && j>w
            p_88(i,j-w)=real_extrect_lsb0(i,j);
            p_555(i,j-w)=real_extrect_lsb2(i,j);
            p_7(i,j-w)=real_extrect_lsb1(i,j);
            p_22(i,j-w)=combine_3_extract(i,j);
        end
        if i>h && j<=w
            p_5(i-h,j)=real_extrect_lsb0(i,j);
             p_66(i-h,j)=real_extrect_lsb2(i,j);
            p_777(i-h,j)=real_extrect_lsb1(i,j);
            p_33(i-h,j)=combine_3_extract(i,j);
        end
      
        if i>h && j>w
            p_888(i-h,j-w)=real_extrect_lsb0(i,j);
            p_6(i-h,j-w)=real_extrect_lsb2(i,j);
            p_77(i-h,j-w)=real_extrect_lsb1(i,j);
            p_44(i-h,j-w)=combine_3_extract(i,j);
        end
    end
end
p_88=rot90(p_88,3);
p_888=rot90(p_888,2);
p_77=rot90(p_77,3);
p_777=rot90(p_777,2);
p_66=rot90(p_66,3);
p_666=rot90(p_666,2);
p_55=rot90(p_55,3);
p_555=rot90(p_555,2);


%Quantum Watermark Recovery
for i=1:h
    for j=1:w
if p_5(i,j)+p_55(i,j)+p_555(i,j)>1
    p_5(i,j)=1;
elseif p_5(i,j)+p_55(i,j)+p_555(i,j)<=1
    p_5(i,j)=0;
end
    end
end

for i=1:h
    for j=1:w
if p_6(i,j)+p_66(i,j)+p_666(i,j)>1
    p_6(i,j)=1;
elseif p_6(i,j)+p_66(i,j)+p_666(i,j)<=1
    p_6(i,j)=0;
end
    end
end
%%%%%%%%%%%%
for i=1:h
    for j=1:w
if p_7(i,j)+p_77(i,j)+p_777(i,j)>1
    p_7(i,j)=1;
elseif p_7(i,j)+p_77(i,j)+p_777(i,j)<=1
    p_7(i,j)=0;
end
    end
end

for i=1:h
    for j=1:w
if p_8(i,j)+p_88(i,j)+p_888(i,j)>1
    p_8(i,j)=1;
elseif p_8(i,j)+p_88(i,j)+p_888(i,j)<=1
    p_8(i,j)=0;
end
    end
end
% % subplot(4,2,1);
% imshow(p1);
% % subplot(4,2,2);
% imshow(p2);
% % subplot(4,2,3);
% imshow(p3);
% % subplot(4,2,4);
% imshow(p4);
% % subplot(4,2,5);
% imshow(p5);
% % subplot(4,2,6);
% imshow(p6);
% % subplot(4,2,7);
% imshow(p7);
% % subplot(4,2,8);
% imshow(p8);
watermark_image_extract=zeros(256,256);
for i=1:256
    for j=1:256
  % watermark_image_extract(i,j)=p_5(i,j)*16+p_6(i,j)*32+p_7(i,j)*64+p_8(i,j)*128; 
%watermark_image_extract(i,j)=plane_4(i,j)*8+plane_3(i,j)*4+plane_2(i,j)*2+plane_1(i,j)*1+p_5(i,j)*16+p_6(i,j)*32+p_7(i,j)*64+p_8(i,j)*128;
watermark_image_extract(i,j)=p_44(i,j)*8+p_33(i,j)*4+p_22(i,j)*2+p_11(i,j)*1+p_5(i,j)*16+p_6(i,j)*32+p_7(i,j)*64+p_8(i,j)*128;
    end
end
watermark_image_extract_show=uint8(watermark_image_extract);
% watermark_image_extract_show=rot90(watermark_image_extract_show,2);
 figure;
 imshow(watermark_image_extract_show);


