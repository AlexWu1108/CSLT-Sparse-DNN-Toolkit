// a supplement for nnet3/nnet-simple-component.cc

// AvgComponent: have linear_params_ divided by 4

void AvgComponent::Propagate(const ComponentPrecomputedIndexes *indexes,
                                    const CuMatrixBase<BaseFloat> &in,
                                    CuMatrixBase<BaseFloat> *out) const {
  // devided by 4
  out->CopyFromMat(in);
  CuMatrix<BaseFloat> tmp(out->NumRows(),out->NumCols());
  tmp.Set(0.25);
  out->MulElements(tmp);
  std::ofstream ofile("/work7/wangyanqing/ofile/Avg");
  ofile.close();
}

void AvgComponent::Backprop(const std::string &debug_info,
                                   const ComponentPrecomputedIndexes *indexes,
                                   const CuMatrixBase<BaseFloat> &, // in_value
                                   const CuMatrixBase<BaseFloat> &out_value,
                                   const CuMatrixBase<BaseFloat> &out_deriv,
                                   Component *, // to_update
                                   CuMatrixBase<BaseFloat> *in_deriv) const {
  if (in_deriv == NULL)
    return;
  in_deriv->DiffLogSoftmaxPerRow(out_value, out_deriv);
}


// NaturalGradientAffineComponentWithFixedZero: similar with NaturalGradientAffineComponent, the only difference
// is that the zeros in linear_params_ will not change when updating parameters.

NaturalGradientAffineComponentWithFixedZero::NaturalGradientAffineComponentWithFixedZero():
    max_change_per_sample_(0.0),
    update_count_(0.0), active_scaling_count_(0.0),
    max_change_scale_stats_(0.0) { }

// virtual
void NaturalGradientAffineComponentWithFixedZero::Resize(
    int32 input_dim, int32 output_dim) {
  KALDI_ASSERT(input_dim > 1 && output_dim > 1);
  if (rank_in_ >= input_dim) rank_in_ = input_dim - 1;
  if (rank_out_ >= output_dim) rank_out_ = output_dim - 1;
  bias_params_.Resize(output_dim);
  linear_params_.Resize(output_dim, input_dim);
  OnlineNaturalGradient temp;
  preconditioner_in_ = temp;
  preconditioner_out_ = temp;
  SetNaturalGradientConfigs();
}


void NaturalGradientAffineComponentWithFixedZero::Read(std::istream &is, bool binary) {
  ReadUpdatableCommon(is, binary);  // Read the opening tag and learning rate
  ExpectToken(is, binary, "<LinearParams>");
  linear_params_.Read(is, binary);
  
  // Modify
  //mask.Resize(linear_params_.NumRows(),linear_params_.NumCols());
  //mask.CopyFromMat(linear_params_);
  //mask.ApplyPowAbs(1);
  //mask.ApplyHeaviside();

  ExpectToken(is, binary, "<BiasParams>");
  bias_params_.Read(is, binary);
  ExpectToken(is, binary, "<RankIn>");
  ReadBasicType(is, binary, &rank_in_);
  ExpectToken(is, binary, "<RankOut>");
  ReadBasicType(is, binary, &rank_out_);
  ExpectToken(is, binary, "<UpdatePeriod>");
  ReadBasicType(is, binary, &update_period_);
  ExpectToken(is, binary, "<NumSamplesHistory>");
  ReadBasicType(is, binary, &num_samples_history_);
  ExpectToken(is, binary, "<Alpha>");
  ReadBasicType(is, binary, &alpha_);
  ExpectToken(is, binary, "<MaxChangePerSample>");
  ReadBasicType(is, binary, &max_change_per_sample_);
  ExpectToken(is, binary, "<IsGradient>");
  ReadBasicType(is, binary, &is_gradient_);
  std::string token;
  ReadToken(is, binary, &token);
  if (token == "<UpdateCount>") {
    ReadBasicType(is, binary, &update_count_);
    ExpectToken(is, binary, "<ActiveScalingCount>");
    ReadBasicType(is, binary, &active_scaling_count_);
    ExpectToken(is, binary, "<MaxChangeScaleStats>");
    ReadBasicType(is, binary, &max_change_scale_stats_);
    ReadToken(is, binary, &token);
  }
  if (token != "<NaturalGradientAffineComponentWithFixedZero>" &&
      token != "</NaturalGradientAffineComponentWithFixedZero>")
    KALDI_ERR << "Expected <NaturalGradientAffineComponentWithFixedZero> or "
              << "</NaturalGradientAffineComponentWithFixedZero>, got " << token;
  SetNaturalGradientConfigs();
}

void NaturalGradientAffineComponentWithFixedZero::InitFromConfig(ConfigLine *cfl) {
  bool ok = true;
  std::string matrix_filename;
  BaseFloat num_samples_history = 2000.0, alpha = 4.0,
      max_change_per_sample = 0.0;
  int32 input_dim = -1, output_dim = -1, rank_in = 20, rank_out = 80,
      update_period = 4;
  InitLearningRatesFromConfig(cfl);
  cfl->GetValue("num-samples-history", &num_samples_history);
  cfl->GetValue("alpha", &alpha);
  cfl->GetValue("max-change-per-sample", &max_change_per_sample);
  cfl->GetValue("rank-in", &rank_in);
  cfl->GetValue("rank-out", &rank_out);
  cfl->GetValue("update-period", &update_period);

  if (cfl->GetValue("matrix", &matrix_filename)) {
    Init(rank_in, rank_out, update_period,
         num_samples_history, alpha, max_change_per_sample,
         matrix_filename);
    if (cfl->GetValue("input-dim", &input_dim))
      KALDI_ASSERT(input_dim == InputDim() &&
                   "input-dim mismatch vs. matrix.");
    if (cfl->GetValue("output-dim", &output_dim))
      KALDI_ASSERT(output_dim == OutputDim() &&
                   "output-dim mismatch vs. matrix.");
  } else {
    ok = ok && cfl->GetValue("input-dim", &input_dim);
    ok = ok && cfl->GetValue("output-dim", &output_dim);
    if (!ok)
      KALDI_ERR << "Bad initializer " << cfl->WholeLine();
    BaseFloat param_stddev = 1.0 / std::sqrt(input_dim),
        bias_stddev = 1.0, bias_mean = 0.0;
    cfl->GetValue("param-stddev", &param_stddev);
    cfl->GetValue("bias-stddev", &bias_stddev);
    cfl->GetValue("bias-mean", &bias_mean);
    Init(input_dim, output_dim, param_stddev,
         bias_stddev, bias_mean, rank_in, rank_out, update_period,
         num_samples_history, alpha, max_change_per_sample);
  }
  if (cfl->HasUnusedValues())
    KALDI_ERR << "Could not process these elements in initializer: "
              << cfl->UnusedValues();
  if (!ok)
    KALDI_ERR << "Bad initializer " << cfl->WholeLine();
}

void NaturalGradientAffineComponentWithFixedZero::SetNaturalGradientConfigs() {
  preconditioner_in_.SetRank(rank_in_);
  preconditioner_in_.SetNumSamplesHistory(num_samples_history_);
  preconditioner_in_.SetAlpha(alpha_);
  preconditioner_in_.SetUpdatePeriod(update_period_);
  preconditioner_out_.SetRank(rank_out_);
  preconditioner_out_.SetNumSamplesHistory(num_samples_history_);
  preconditioner_out_.SetAlpha(alpha_);
  preconditioner_out_.SetUpdatePeriod(update_period_);
}

void NaturalGradientAffineComponentWithFixedZero::Init(
    int32 rank_in, int32 rank_out,
    int32 update_period, BaseFloat num_samples_history, BaseFloat alpha,
    BaseFloat max_change_per_sample,
    std::string matrix_filename) {
  rank_in_ = rank_in;
  rank_out_ = rank_out;
  update_period_ = update_period;
  num_samples_history_ = num_samples_history;
  alpha_ = alpha;
  SetNaturalGradientConfigs();
  KALDI_ASSERT(max_change_per_sample >= 0.0);
  max_change_per_sample_ = max_change_per_sample;
  CuMatrix<BaseFloat> mat;
  ReadKaldiObject(matrix_filename, &mat); // will abort on failure.
  KALDI_ASSERT(mat.NumCols() >= 2);
  int32 input_dim = mat.NumCols() - 1, output_dim = mat.NumRows();
  linear_params_.Resize(output_dim, input_dim);
  bias_params_.Resize(output_dim);
  linear_params_.CopyFromMat(mat.Range(0, output_dim, 0, input_dim));
  bias_params_.CopyColFromMat(mat, input_dim);
  is_gradient_ = false;  // not configurable; there's no reason you'd want this
  update_count_ = 0.0;
  active_scaling_count_ = 0.0;
  max_change_scale_stats_ = 0.0;
}

void NaturalGradientAffineComponentWithFixedZero::Init(
    int32 input_dim, int32 output_dim,
    BaseFloat param_stddev, BaseFloat bias_stddev, BaseFloat bias_mean,
    int32 rank_in, int32 rank_out, int32 update_period,
    BaseFloat num_samples_history, BaseFloat alpha,
    BaseFloat max_change_per_sample) {
  linear_params_.Resize(output_dim, input_dim);
  bias_params_.Resize(output_dim);
  KALDI_ASSERT(output_dim > 0 && input_dim > 0 && param_stddev >= 0.0 &&
               bias_stddev >= 0.0);
  linear_params_.SetRandn(); // sets to random normally distributed noise.
  linear_params_.Scale(param_stddev);
  bias_params_.SetRandn();
  bias_params_.Scale(bias_stddev);
  bias_params_.Add(bias_mean);
  rank_in_ = rank_in;
  rank_out_ = rank_out;
  update_period_ = update_period;
  num_samples_history_ = num_samples_history;
  alpha_ = alpha;
  SetNaturalGradientConfigs();
  if (max_change_per_sample > 0.0)
    KALDI_WARN << "You are setting a positive max_change_per_sample for "
               << "NaturalGradientAffineComponentWithFixedZero. But it has been deprecated. "
               << "Please use max_change for all updatable components instead "
               << "to activate the per-component max change mechanism.";
  KALDI_ASSERT(max_change_per_sample >= 0.0);
  max_change_per_sample_ = max_change_per_sample;
  is_gradient_ = false;  // not configurable; there's no reason you'd want this
  update_count_ = 0.0;
  active_scaling_count_ = 0.0;
  max_change_scale_stats_ = 0.0;
}

void NaturalGradientAffineComponentWithFixedZero::Write(std::ostream &os,
                                           bool binary) const {
  WriteUpdatableCommon(os, binary);  // Write the opening tag and learning rate
  WriteToken(os, binary, "<LinearParams>");
  linear_params_.Write(os, binary);
  WriteToken(os, binary, "<BiasParams>");
  bias_params_.Write(os, binary);
  WriteToken(os, binary, "<RankIn>");
  WriteBasicType(os, binary, rank_in_);
  WriteToken(os, binary, "<RankOut>");
  WriteBasicType(os, binary, rank_out_);
  WriteToken(os, binary, "<UpdatePeriod>");
  WriteBasicType(os, binary, update_period_);
  WriteToken(os, binary, "<NumSamplesHistory>");
  WriteBasicType(os, binary, num_samples_history_);
  WriteToken(os, binary, "<Alpha>");
  WriteBasicType(os, binary, alpha_);
  WriteToken(os, binary, "<MaxChangePerSample>");
  WriteBasicType(os, binary, max_change_per_sample_);
  WriteToken(os, binary, "<IsGradient>");
  WriteBasicType(os, binary, is_gradient_);
  WriteToken(os, binary, "<UpdateCount>");
  WriteBasicType(os, binary, update_count_);
  WriteToken(os, binary, "<ActiveScalingCount>");
  WriteBasicType(os, binary, active_scaling_count_);
  WriteToken(os, binary, "<MaxChangeScaleStats>");
  WriteBasicType(os, binary, max_change_scale_stats_);
  WriteToken(os, binary, "</NaturalGradientAffineComponentWithFixedZero>");
}

std::string NaturalGradientAffineComponentWithFixedZero::Info() const {
  std::ostringstream stream;
  stream << UpdatableComponent::Info();
  PrintParameterStats(stream, "linear-params", linear_params_);
  PrintParameterStats(stream, "bias", bias_params_, true);
  stream << ", rank-in=" << rank_in_
         << ", rank-out=" << rank_out_
         << ", num_samples_history=" << num_samples_history_
         << ", update_period=" << update_period_
         << ", alpha=" << alpha_
         << ", max-change-per-sample=" << max_change_per_sample_;
  if (update_count_ > 0.0 && max_change_per_sample_ > 0.0) {
    stream << ", avg-scaling-factor=" << max_change_scale_stats_ / update_count_
           << ", active-scaling-portion="
           << active_scaling_count_ / update_count_;
  }
  return stream.str();
}

Component* NaturalGradientAffineComponentWithFixedZero::Copy() const {
  return new NaturalGradientAffineComponentWithFixedZero(*this);
}

NaturalGradientAffineComponentWithFixedZero::NaturalGradientAffineComponentWithFixedZero(
    const NaturalGradientAffineComponentWithFixedZero &other):
    AffineComponent(other),
    rank_in_(other.rank_in_),
    rank_out_(other.rank_out_),
    update_period_(other.update_period_),
    num_samples_history_(other.num_samples_history_),
    alpha_(other.alpha_),
    preconditioner_in_(other.preconditioner_in_),
    preconditioner_out_(other.preconditioner_out_),
    max_change_per_sample_(other.max_change_per_sample_),
    update_count_(other.update_count_),
    active_scaling_count_(other.active_scaling_count_),
    max_change_scale_stats_(other.max_change_scale_stats_) {
  SetNaturalGradientConfigs();
}

void NaturalGradientAffineComponentWithFixedZero::Update(
    const std::string &debug_info,
    const CuMatrixBase<BaseFloat> &in_value,
    const CuMatrixBase<BaseFloat> &out_deriv,
    CuMatrixBase<BaseFloat> &mask) {
  std::ofstream of("/work7/wangyanqing/route.txt",std::ios::app);
  of<<"Updating...\n";
  of.close();
//  mask.Write(of,false);
//  of.close();
  CuMatrix<BaseFloat> in_value_temp;
  //std::ofstream ofile;
  //ofile.open("/work7/wangyanqing/debug_output.txt",std::ios::app);

  in_value_temp.Resize(in_value.NumRows(),
                       in_value.NumCols() + 1, kUndefined);
  in_value_temp.Range(0, in_value.NumRows(),
                      0, in_value.NumCols()).CopyFromMat(in_value);

  // Add the 1.0 at the end of each row "in_value_temp"
  in_value_temp.Range(0, in_value.NumRows(),
                      in_value.NumCols(), 1).Set(1.0);
  //ofile<<"in_value_temp\n";
  //in_value_temp.Write(ofile,false);
  CuMatrix<BaseFloat> out_deriv_temp(out_deriv);
//  CuMatrix<BaseFloat> mask(out_deriv);

  CuMatrix<BaseFloat> row_products(2,
                                   in_value.NumRows());
  CuSubVector<BaseFloat> in_row_products(row_products, 0),
      out_row_products(row_products, 1);

  // These "scale" values get will get multiplied into the learning rate (faster
  // than having the matrices scaled inside the preconditioning code).

  BaseFloat in_scale, out_scale;

  preconditioner_in_.PreconditionDirections(&in_value_temp, &in_row_products,
                                            &in_scale);
  preconditioner_out_.PreconditionDirections(&out_deriv_temp, &out_row_products,
                                             &out_scale);
  
  // "scale" is a scaling factor coming from the PreconditionDirections calls
  // (it's faster to have them output a scaling factor than to have them scale
  // their outputs).
  
  BaseFloat scale = in_scale * out_scale;

  CuSubMatrix<BaseFloat> in_value_precon_part(in_value_temp,
                                              0, in_value_temp.NumRows(),
                                              0, in_value_temp.NumCols() - 1);
  
  // this "precon_ones" is what happens to the vector of 1's representing
  // offsets, after multiplication by the preconditioner.
  CuVector<BaseFloat> precon_ones(in_value_temp.NumRows());

  precon_ones.CopyColFromMat(in_value_temp, in_value_temp.NumCols() - 1);

  BaseFloat local_lrate = scale * learning_rate_;
  update_count_ += 1.0;
  bias_params_.AddMatVec(local_lrate, out_deriv_temp, kTrans,
                         precon_ones, 1.0);
  //ofile<<"out_deriv_temp:\n";
  //out_deriv_temp.Write(ofile,false);
  //ofile<<"in_value_precon_part:\n";
  //in_value_precon_part.Write(ofile,false);
//  ofile<<"linear_params_:\n";
//  linear_params_.Write(ofile,false);
//  linear_params_.AddMatMat(local_lrate, out_deriv_temp, kTrans,
//                           in_value_precon_part, kNoTrans, 1.0);
//  ofile<<"new:\n";
//  linear_params_.Write(ofile,false);
//  ofile.close();
  
  //out_deriv_temp.SetZero();

  // Modify
  // calculate the mask

//  ofile<<"linear_params_\n";
//  linear_params_.Write(ofile,false);
//  CuMatrix<BaseFloat> mask(linear_params_);
//  ofile<<"mask_orig\n";
//  mask.Write(ofile,false);
//  ofile<<"mask_new\n";
//  Matrix<BaseFloat> mask_mat(mask);
//  mask_mat.ApplyHeaviside();
//  mask.CopyFromMat(mask_mat);
//  mask.Write(ofile,false);

  // Method 2
  CuMatrix<BaseFloat> MatAdded(linear_params_.NumRows(),linear_params_.NumCols());
  Matrix<BaseFloat> MatAdded_mat(MatAdded);
  Matrix<BaseFloat> out_deriv_temp_mat(out_deriv_temp);
  Matrix<BaseFloat> in_value_mat(in_value_precon_part);
  cblas_Xgemm(local_lrate,kTrans,out_deriv_temp_mat.Data(),out_deriv_temp_mat.NumRows(),out_deriv_temp_mat.NumCols(),out_deriv_temp_mat.Stride(),kNoTrans,in_value_mat.Data(),in_value_mat.Stride(),1.0,MatAdded_mat.Data(),MatAdded_mat.NumRows(),MatAdded_mat.NumCols(),MatAdded_mat.Stride());
  MatAdded.CopyFromMat(MatAdded_mat);
  MatAdded.MulElements(mask);
  linear_params_.AddMat(1.0,MatAdded);

//  std::ofstream ofile;
//  ofile.open("/work7/wangyanqing/mask.txt",std::ios::app);
//  //ofile<<"lin "<<linear_params_.NumRows()<<" "<<linear_params_.NumCols()<<"\n";
//  //ofile<<"Mat "<<MatAdded.NumRows()<<" "<<MatAdded.NumCols()<<"\n";
//  ofile<<"mask_para:"<<mask.NumRows()<<" "<<mask.NumCols()<<"\n";
//  ofile<<"mask:\n";
//  mask.Write(ofile,false);
//  ofile<<"matadded_para:"<<MatAdded.NumRows()<<" "<<MatAdded.NumCols()<<"\n";
//  ofile<<"matadded:\n";
//  MatAdded.Write(ofile,false);
//  ofile.close();



//  Matrix<BaseFloat> mask_mat(mask);
//  mask_mat.ApplyHeaviside();
//  mask.CopyFromMat(mask_mat);
//
//  CuMatrix<BaseFloat> MatAdded(out_deriv_temp);
//  MatAdded.MulElements(mask);
//  linear_params_.AddMatMat(local_lrate, MatAdded, kTrans,
//                           in_value_precon_part, kNoTrans, 1.0);

//  ctrl_mask = 0;
  
}


void NaturalGradientAffineComponentWithFixedZero::ZeroStats()  {
  update_count_ = 0.0;
  max_change_scale_stats_ = 0.0;
  active_scaling_count_ = 0.0;
}

void NaturalGradientAffineComponentWithFixedZero::Scale(BaseFloat scale) {
  if (scale == 0.0) {
    update_count_ = 0.0;
    max_change_scale_stats_ = 0.0;
    active_scaling_count_ = 0.0;
    linear_params_.SetZero();
    bias_params_.SetZero();
  } else {
    update_count_ *= scale;
    max_change_scale_stats_ *= scale;
    active_scaling_count_ *= scale;
    linear_params_.Scale(scale);
    bias_params_.Scale(scale);
  }
}

void NaturalGradientAffineComponentWithFixedZero::Add(BaseFloat alpha, const Component &other_in) {
  const NaturalGradientAffineComponentWithFixedZero *other =
      dynamic_cast<const NaturalGradientAffineComponentWithFixedZero*>(&other_in);
  KALDI_ASSERT(other != NULL);
  
  // Modify
  //std::ofstream ofile;
  //ofile.open("/work7/wangyanqing/debug.txt",std::ios::app);
  //ofile<<"linear:\n";
  //linear_params_.Write(ofile,false);
  
  // Calc the Mask
  //CuMatrix<BaseFloat> mask = linear_params_;
  //mask.ApplyHeaviside();

  update_count_ += alpha * other->update_count_;
  max_change_scale_stats_ += alpha * other->max_change_scale_stats_;
  active_scaling_count_ += alpha * other->active_scaling_count_;

  // Mask
  //CuMatrix<BaseFloat> MatrixAdded = other->linear_params_;
  //MatrixAdded.MulElements(mask);

  linear_params_.AddMat(alpha, other->linear_params_);
  // Modify
  //ofile<<"new:\n";
  //linear_params_.Write(ofile,false);
  bias_params_.AddVec(alpha, other->bias_params_);
}