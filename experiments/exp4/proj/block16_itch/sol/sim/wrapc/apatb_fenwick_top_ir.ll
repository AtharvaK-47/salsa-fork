; ModuleID = 'C:/gitrepos/salsa-fork/experiments/exp4/proj/block16_itch/sol/.autopilot/db/a.g.ld.5.gdce.bc'
source_filename = "llvm-link"
target datalayout = "e-m:e-i64:64-i128:128-i256:256-i512:512-i1024:1024-i2048:2048-i4096:4096-n8:16:32:64-S128-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
target triple = "fpga64-xilinx-none"

; Function Attrs: noinline
define void @apatb_fenwick_top_ir(i16* noalias nocapture nonnull readonly "fpga.decayed.dim.hint"="100000" %keys, i8* noalias nocapture nonnull readonly "fpga.decayed.dim.hint"="100000" %kinds, i32* noalias nocapture nonnull readonly "fpga.decayed.dim.hint"="100000" %vals, i32* noalias nocapture nonnull "fpga.decayed.dim.hint"="100000" %res, i32 %n) local_unnamed_addr #0 {
entry:
  %0 = bitcast i16* %keys to [100000 x i16]*
  %1 = call i8* @malloc(i64 200000)
  %keys_copy = bitcast i8* %1 to [100000 x i16]*
  %2 = bitcast i8* %kinds to [100000 x i8]*
  %3 = call i8* @malloc(i64 100000)
  %kinds_copy = bitcast i8* %3 to [100000 x i8]*
  %4 = bitcast i32* %vals to [100000 x i32]*
  %5 = call i8* @malloc(i64 400000)
  %vals_copy = bitcast i8* %5 to [100000 x i32]*
  %6 = bitcast i32* %res to [100000 x i32]*
  %7 = call i8* @malloc(i64 400000)
  %res_copy = bitcast i8* %7 to [100000 x i32]*
  call fastcc void @copy_in([100000 x i16]* nonnull %0, [100000 x i16]* %keys_copy, [100000 x i8]* nonnull %2, [100000 x i8]* %kinds_copy, [100000 x i32]* nonnull %4, [100000 x i32]* %vals_copy, [100000 x i32]* nonnull %6, [100000 x i32]* %res_copy)
  call void @apatb_fenwick_top_hw([100000 x i16]* %keys_copy, [100000 x i8]* %kinds_copy, [100000 x i32]* %vals_copy, [100000 x i32]* %res_copy, i32 %n)
  call void @copy_back([100000 x i16]* %0, [100000 x i16]* %keys_copy, [100000 x i8]* %2, [100000 x i8]* %kinds_copy, [100000 x i32]* %4, [100000 x i32]* %vals_copy, [100000 x i32]* %6, [100000 x i32]* %res_copy)
  tail call void @free(i8* %1)
  tail call void @free(i8* %3)
  tail call void @free(i8* %5)
  tail call void @free(i8* %7)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_in([100000 x i16]* readonly, [100000 x i16]*, [100000 x i8]* readonly, [100000 x i8]*, [100000 x i32]* readonly, [100000 x i32]*, [100000 x i32]* readonly, [100000 x i32]*) unnamed_addr #1 {
entry:
  call fastcc void @onebyonecpy_hls.p0a100000i16([100000 x i16]* %1, [100000 x i16]* %0)
  call fastcc void @onebyonecpy_hls.p0a100000i8([100000 x i8]* %3, [100000 x i8]* %2)
  call fastcc void @onebyonecpy_hls.p0a100000i32([100000 x i32]* %5, [100000 x i32]* %4)
  call fastcc void @onebyonecpy_hls.p0a100000i32([100000 x i32]* %7, [100000 x i32]* %6)
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @onebyonecpy_hls.p0a100000i16([100000 x i16]* %dst, [100000 x i16]* readonly %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [100000 x i16]* %dst, null
  %1 = icmp eq [100000 x i16]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a100000i16([100000 x i16]* nonnull %dst, [100000 x i16]* nonnull %src, i64 100000)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a100000i16([100000 x i16]* %dst, [100000 x i16]* readonly %src, i64 %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [100000 x i16]* %src, null
  %1 = icmp eq [100000 x i16]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [100000 x i16], [100000 x i16]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [100000 x i16], [100000 x i16]* %src, i64 0, i64 %for.loop.idx2
  %3 = load i16, i16* %src.addr, align 2
  store i16 %3, i16* %dst.addr, align 2
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @onebyonecpy_hls.p0a100000i8([100000 x i8]* %dst, [100000 x i8]* readonly %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [100000 x i8]* %dst, null
  %1 = icmp eq [100000 x i8]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a100000i8([100000 x i8]* nonnull %dst, [100000 x i8]* nonnull %src, i64 100000)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a100000i8([100000 x i8]* %dst, [100000 x i8]* readonly %src, i64 %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [100000 x i8]* %src, null
  %1 = icmp eq [100000 x i8]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [100000 x i8], [100000 x i8]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [100000 x i8], [100000 x i8]* %src, i64 0, i64 %for.loop.idx2
  %3 = load i8, i8* %src.addr, align 1
  store i8 %3, i8* %dst.addr, align 1
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @onebyonecpy_hls.p0a100000i32([100000 x i32]* %dst, [100000 x i32]* readonly %src) unnamed_addr #2 {
entry:
  %0 = icmp eq [100000 x i32]* %dst, null
  %1 = icmp eq [100000 x i32]* %src, null
  %2 = or i1 %0, %1
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  call void @arraycpy_hls.p0a100000i32([100000 x i32]* nonnull %dst, [100000 x i32]* nonnull %src, i64 100000)
  br label %ret

ret:                                              ; preds = %copy, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define void @arraycpy_hls.p0a100000i32([100000 x i32]* %dst, [100000 x i32]* readonly %src, i64 %num) local_unnamed_addr #3 {
entry:
  %0 = icmp eq [100000 x i32]* %src, null
  %1 = icmp eq [100000 x i32]* %dst, null
  %2 = or i1 %1, %0
  br i1 %2, label %ret, label %copy

copy:                                             ; preds = %entry
  %for.loop.cond1 = icmp sgt i64 %num, 0
  br i1 %for.loop.cond1, label %for.loop.lr.ph, label %copy.split

for.loop.lr.ph:                                   ; preds = %copy
  br label %for.loop

for.loop:                                         ; preds = %for.loop, %for.loop.lr.ph
  %for.loop.idx2 = phi i64 [ 0, %for.loop.lr.ph ], [ %for.loop.idx.next, %for.loop ]
  %dst.addr = getelementptr [100000 x i32], [100000 x i32]* %dst, i64 0, i64 %for.loop.idx2
  %src.addr = getelementptr [100000 x i32], [100000 x i32]* %src, i64 0, i64 %for.loop.idx2
  %3 = load i32, i32* %src.addr, align 4
  store i32 %3, i32* %dst.addr, align 4
  %for.loop.idx.next = add nuw nsw i64 %for.loop.idx2, 1
  %exitcond = icmp ne i64 %for.loop.idx.next, %num
  br i1 %exitcond, label %for.loop, label %copy.split

copy.split:                                       ; preds = %for.loop, %copy
  br label %ret

ret:                                              ; preds = %copy.split, %entry
  ret void
}

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_out([100000 x i16]*, [100000 x i16]* readonly, [100000 x i8]*, [100000 x i8]* readonly, [100000 x i32]*, [100000 x i32]* readonly, [100000 x i32]*, [100000 x i32]* readonly) unnamed_addr #4 {
entry:
  call fastcc void @onebyonecpy_hls.p0a100000i16([100000 x i16]* %0, [100000 x i16]* %1)
  call fastcc void @onebyonecpy_hls.p0a100000i8([100000 x i8]* %2, [100000 x i8]* %3)
  call fastcc void @onebyonecpy_hls.p0a100000i32([100000 x i32]* %4, [100000 x i32]* %5)
  call fastcc void @onebyonecpy_hls.p0a100000i32([100000 x i32]* %6, [100000 x i32]* %7)
  ret void
}

declare i8* @malloc(i64) local_unnamed_addr

declare void @free(i8*) local_unnamed_addr

declare void @apatb_fenwick_top_hw([100000 x i16]* %keys, [100000 x i8]* %kinds, [100000 x i32]* %vals, [100000 x i32]* %res, i32 %n)

; Function Attrs: argmemonly noinline norecurse willreturn
define internal fastcc void @copy_back([100000 x i16]*, [100000 x i16]* readonly, [100000 x i8]*, [100000 x i8]* readonly, [100000 x i32]*, [100000 x i32]* readonly, [100000 x i32]*, [100000 x i32]* readonly) unnamed_addr #4 {
entry:
  call fastcc void @onebyonecpy_hls.p0a100000i32([100000 x i32]* %6, [100000 x i32]* %7)
  ret void
}

declare void @fenwick_top_hw_stub(i16* noalias nocapture nonnull readonly, i8* noalias nocapture nonnull readonly, i32* noalias nocapture nonnull readonly, i32* noalias nocapture nonnull, i32)

define void @fenwick_top_hw_stub_wrapper([100000 x i16]* %keys, [100000 x i8]* %kinds, [100000 x i32]* %vals, [100000 x i32]* %res, i32 %n) #5 {
entry:
  call void @copy_out([100000 x i16]* null, [100000 x i16]* %keys, [100000 x i8]* null, [100000 x i8]* %kinds, [100000 x i32]* null, [100000 x i32]* %vals, [100000 x i32]* null, [100000 x i32]* %res)
  %0 = bitcast [100000 x i16]* %keys to i16*
  %1 = bitcast [100000 x i8]* %kinds to i8*
  %2 = bitcast [100000 x i32]* %vals to i32*
  %3 = bitcast [100000 x i32]* %res to i32*
  call void @fenwick_top_hw_stub(i16* %0, i8* %1, i32* %2, i32* %3, i32 %n)
  call void @copy_in([100000 x i16]* null, [100000 x i16]* %keys, [100000 x i8]* null, [100000 x i8]* %kinds, [100000 x i32]* null, [100000 x i32]* %vals, [100000 x i32]* null, [100000 x i32]* %res)
  ret void
}

attributes #0 = { noinline "fpga.wrapper.func"="wrapper" }
attributes #1 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="copyin" }
attributes #2 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="onebyonecpy_hls" }
attributes #3 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="arraycpy_hls" }
attributes #4 = { argmemonly noinline norecurse willreturn "fpga.wrapper.func"="copyout" }
attributes #5 = { "fpga.wrapper.func"="stub" }

!llvm.dbg.cu = !{}
!llvm.ident = !{!0, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1, !1}
!llvm.module.flags = !{!2, !3, !4}
!blackbox_cfg = !{!5}

!0 = !{!"AMD/Xilinx clang version 16.0.6"}
!1 = !{!"clang version 7.0.0 "}
!2 = !{i32 2, !"Dwarf Version", i32 4}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{}
